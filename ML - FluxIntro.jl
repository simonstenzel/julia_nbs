### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 5b9e0eda-ba4c-11ec-05c8-07ccdc39ccb8
begin
	using Flux
	using Plots
	using PlutoUI
end

# ╔═╡ 9171f9b1-b139-4408-8d9d-186ffb0819b0
using Flux: train!

# ╔═╡ 7e63fbb7-5260-463a-9e8d-dea6b3bf3ed4
html"""
<div style="
position: absolute;
width: calc(100% - 30px);
border: 50vw solid SteelBlue;
border-top: 500px solid SteelBlue;
border-bottom: none;
box-sizing: content-box;
left: calc(-50vw + 15px);
top: -500px;
height: 300px;
pointer-events: none;
"></div>

<div style="
height: 300px;
width: 100%;
background: SteelBlue;
color: #88BBD6;
padding-top: 68px;
padding-left: 5px;
">

<span style="
font-family: Vollkorn, serif;
font-weight: 700;
font-feature-settings: 'lnum', 'pnum';
"> 

<p style="
font-family: Alegreya sans;
font-size: 1.4rem;
font-weight: 300;
opacity: 1.0;
color: #CDCDCD;
">Data Mining & Machine Learning</p>
<p style="text-align: left; font-size: 2.8rem;">
Eine Einführung in Flux.jl
</p>
</br></br></br>

<p style="
font-family: 'Alegreya Sans'; 
font-size: 0.7rem; 
font-weight: 300;
color: #CDCDCD;">

&copy  Dr. Roland Schätzle
</p>
"""

# ╔═╡ f4f96036-a408-43c7-a481-70c125dbd144
PlutoUI.TableOfContents(title = "Flux")

# ╔═╡ 63bfcfd4-8597-4b2f-b7de-61058f39d6c7
html"<button onclick='present()'>present</button>"

# ╔═╡ 933de385-f043-4e0d-9a78-61b7f63e048a
md"""
# Flux

[`Flux.jl`](https://fluxml.ai/Flux.jl/stable/) ist *das* Package für Machine Learning mit Neuronalen Netzen (NN) in Julia. Im Folgenden ein Auszug aus der Dokumentation, der die wesentlichen Eigenschaften des Package erläutert:
"""

# ╔═╡ a3280ef2-7317-49a6-8f81-2fd9440a0b3b
md"""
>**Flux: The Julia Machine Learning Library**
>
> Flux is a library for machine learning geared towards high-performance production pipelines. It comes "batteries-included" with many useful tools built in, but also lets you use the full power of the Julia language where you need it. We follow a few key principles:
> - Doing the obvious thing. Flux has relatively few explicit APIs for features like regularisation or embeddings. Instead, writing down the mathematical form will work – and be fast.
> - Extensible by default. Flux is written to be highly extensible and flexible while being performant. Extending Flux is as simple as using your own code as part of the model you want - it is all high level Julia code. When in doubt, it’s well worth looking at the source. If you need something different, you can easily roll your own.
> - Performance is key. Flux integrates with high-performance AD tools such as [Zygote.jl](https://github.com/FluxML/Zygote.jl) for generating fast code. Flux optimizes both CPU and GPU performance. Scaling workloads easily to multiple GPUs can be done with the help of Julia's GPU tooling and projects like [DaggerFlux.jl](https://github.com/DhairyaLGandhi/DaggerFlux.jl).
> - Play nicely with others. Flux works well with Julia libraries from data frames and images to differential equation solvers, so you can easily build complex data processing pipelines that integrate Flux models.

"""

# ╔═╡ 175abc83-7996-4ec3-82bd-d58a72de6f6d
md"""
# Automatic Differentiation (AD)

Das Trainieren und Optimieren von NN ist sehr rechenaufwändig. Ein wichtiger Aspekt der verwendeten Algorithmen ist die Berechnung von Gradienten (Ableitungen bei mehrdimensionalen Funktionen). Dafür werden Verfahren zum automatisierten Differenzieren verwendet. Je effizienter dies erfolgt, um so effizienter sind die darauf basierenden Algorithmen. 

Die gängigen Verfahren ("AutoDiff") nutzen dabei eine Mischung von symbolischen und numerischen Ansätzen. Symbolisches Differenzieren benötigt Zugriff auf den Quellcode der betrachteten Funktion. Deshalb arbeiten einige dieser Ansätze mit interpretierten Sprachen (und damit mit einer inhärent wenig performanten Umgebung) oder mit speziellen Konzepten für kompilierte Sprachen, die jedoch den Funktionsumfang einschränken.

Hier hat Julia durch den Ansatz des JIT-Compilers konzeptionelle Vorteile. Beim Differenzieren findet ein Code-Rewriting statt. Der resultierende Code wird dann kompiliert und ist entsprechend effizient. Dies wurde u.a. im `ReverseDiff.jl`-Package umgesetzt.

Einen noch weitergehenden Ansatz implementiert das Package `Zygote.jl`. Es stellt aktuell eine der führenden Umsetzungen von AD dar (s. M. INNES: [*Don't unroll adjoint: Differentiating SSA-form programms*](https://arxiv.org/abs/1810.07951)). Dieses Package wird auch in Flux eingesetzt.
"""

# ╔═╡ c39a00c7-43ad-4b83-8741-c776eead3ae8
md"""
Folgende Tabelle zeigt entsprechende Benchmarkzahlen aus dem o.g. Paper von Michael Innes:

| Benchmark | Forward | Zygote | PyTorch | ReverseDiff |
| :-------- | ------: | -----: | ------: | ----------: |
| SinCos | 15,9 ns | 20,7 ns | 69.900 ns | 670 ns |
| Loop   | 4,17 $\mu$s | 29,5 $\mu$s | 17.500 $\mu$s | 171 $\mu$s |
| LogSumExp | 0,96 $\mu$s | 1,26 $\mu$s | 219 $\mu$s | 15,9 $\mu$s |
| LogisticRegression | 4,67 $\mu$s | 17,6 $\mu$s | 142 $\mu$s | 89,9 $\mu$s |
| 2-Layer MINST MLP | 27,7 $\mu$s | 207 $\mu$s | 369 $\mu$s | N/A |

- *Forward*: Manuelle Implementierung der diff. Funktion in Julia
- *Zygote*: Verwendung des Zygote.jl-Package 
- *PyTorch*: auf Python basierende ML-Bibliothek (vom KI-Team von Facebook entwickelt)
- *ReverseDiff*: Verwendung ds ReverseDiff.jl-Package

"""

# ╔═╡ 2647373e-49f3-45ce-84c1-c5adb96a0545
md"""
## Beispiele
"""

# ╔═╡ 04440986-406a-4793-9e92-eb775de23495
md"""
### Funktion mit einer Variablen
"""

# ╔═╡ 30545456-fb29-498a-85db-3d842edaf550
f(x) = 3x^2 + 2x + 1

# ╔═╡ dc461f63-b8e7-4055-9e98-62228d29f4f0
md"""
Die Ableitung der Funktion 

$f(x) = 3x^2 + 2x + 1$ ist bekanntlich 

$f'(x) = 6x + 2$ 

und wird mit folgendem Aufruf von `gradient` ermittelt:
"""

# ╔═╡ 1c5b8847-9da1-4808-8fe5-9075450d3ab5
df(x) = gradient(f, x)[1]

# ╔═╡ 1bca5c8f-15c3-43ee-af90-40657e6f64f4
md"""
*Hinweis*: Die ermittelte Ableitung liefert immer ein Tupel. Um für den Fall einer skalaren Funktion auch einen einzlenen Wert aus der Ableitung zu erhalten, wird der Ausdruck mit `[1]` auf das erste Element des Tupels beschränkt.
"""

# ╔═╡ 150ca9bf-1dc0-4889-a272-8a8a31a8c345
df(2)

# ╔═╡ 01e41b40-5858-4fd8-8794-bb5009fb4232
md"""
Nach dem gleichen Prinzip kann auch die zweite Ableitung $f''(x) = 6$ ermittelt werden.
"""

# ╔═╡ a59df77e-c280-4eef-8485-816a8afc6fac
d2f(x) = gradient(df, x)[1]

# ╔═╡ a2441e17-e25d-4656-8382-86a8c5aec4f1
d2f(2)

# ╔═╡ 33a91ebe-1d0d-4331-a46c-a49bbd6229bf
md"""
### ... und mit zwei Variablen
"""

# ╔═╡ 4f597419-eec8-43b0-a9de-f9264640109d
g(x, y) = 3x^3 + 5y^2 + 1

# ╔═╡ 91b8f6a6-5cf5-4a70-817d-346dc6d9fa36
md"""
Hier nun die Funktion 

$g(x,y) = 3x^3 + 5y^2 + 1$. 

Deren Ableitung nach $x$ lautet 

$\frac{\partial}{\partial x}g(x,y) = 9x^2$. 

Die Ableitung nach $y$ ist: 

$\frac{\partial}{\partial y}g(x,y) = 10y$
"""

# ╔═╡ cae3ac1c-4cb2-4e9e-ac3f-f562040eea35
dg(x, y) = gradient(g, x, y)

# ╔═╡ 5918ddd9-e67b-46e4-8a60-31868857036b
md"""
`gradient` liefert bei Funktionen mit mehr als einer Variablen immer alle partiellen Ableitungen (hier also nach $dx$ als auch nach $dy$).
"""

# ╔═╡ 0e969a60-2290-4d82-b99d-450142327594
dg(2, 2)

# ╔═╡ f5b45a25-70b7-41a1-90c0-476fa8d693df
md"""
# Ein ganz einfaches Modell
"""

# ╔═╡ c262f6a3-8df6-41f6-83de-bc7874dfd4a8
md"""
Im Folgenden sollen mit einzelnen Neuronen (also quasi minimalen Neuronalen Netzen) lineare Modelle erstellt, mit entsprechenden Daten trainiert und zur Vorhersage genutzt werden.
"""

# ╔═╡ 7579db47-61f6-46c0-994f-5885a5887aab
md"""
## Erzeugung von Trainings- und Testdaten
"""

# ╔═╡ 1b9aac58-dc41-4ade-9704-b994bf9d39cd
actual(x) = 4x + 2

# ╔═╡ c1dc7783-cdda-4197-830a-93149f516df3
plt = plot(actual, xlims = (0, 11), 
	label = "actual", leg = :outerright)

# ╔═╡ fef5f51a-c126-4d9b-9b91-178ce42987e6
md"""
Als Trainings- und Testdaten (auf der X-Achse) werden hier die Zahlen von 0 bis 5 bzw. von 6 bis 10 verwendet.
"""

# ╔═╡ 2fa9aab2-73af-434d-9ed5-79c127ee473b
x_train, x_test = hcat(0:5...), hcat(6:10...)

# ╔═╡ d0ae088b-c03d-4693-8e82-df84b4bb5e4a
md"""
... und die korrespondierenden y-Werte mittels `actual` berechnet.
"""

# ╔═╡ bd1d519c-dcd9-48d1-a25e-e7bed79b6ca8
y_train, y_test = actual.(x_train), actual.(x_test)

# ╔═╡ fa1e8df6-c040-4694-b747-f87377594616
md"""
Die Visualisierung zeigt, dass sowohl die Trainingsdaten (blau) als auch die Testdaten (rot) exakt auf der durch `actual` bestimmten Geraden liegen.
"""

# ╔═╡ b8193edf-9b8a-4020-a04f-3683a0350825
begin
	scatter!(plt, x_train[1,:], y_train[1,:], 
		mc = :blue, alpha = 0.5, label = "train")
	scatter!(plt, x_test[1,:], y_test[1,:], 
		mc = :red, alpha = 0.5, label = "test")
end

# ╔═╡ 148f4f27-22ef-495f-b702-b1cb056a6ac5
md"""
## Das Modell
"""

# ╔═╡ c33ab974-e8ea-4534-b47a-328e9a393ead
md"""
 Ein ("Dense"-)Neuron ist in Flux eine Funktion der Form $\sigma(Wx + b)$. Dabei sind:
-  $\sigma$: Die **Aktivierungsfunktion** (Default: Identität)
-  $W$ eine $n \times m$-Matrix von **Gewichten**
-  $b$ der sog. **Bias** (Schwellenwert)
"""

# ╔═╡ 1b938c7e-43c2-4d99-9db5-09cd9b52d4d7
md"""
Das einfachste Modell dieser Art hat einen Eingangs- und einen Ausgangswert. $W$ ist somit eine $1 \times 1$-Matrix:
"""

# ╔═╡ b5b4783b-7b6f-48d7-9576-42bf104e6886
model = Dense(1 => 1)

# ╔═╡ 816a7308-e11b-407b-91f9-719c139cd4ff
(model.weight, model.bias)

# ╔═╡ 788c8387-075d-4f09-9250-f9e62051e42b
md"""
Die Parameter dieses Models sind zunächst zufällig gewählt.
"""

# ╔═╡ 4ff17862-19cc-4d9d-aa09-ad40830bbffa
md"""
Man kann dieses einfache Neuron auch als Vorhersagemodell betrachten. Deshalb nennen wir es nun `predict` und führen auf Basis der Trainingsdaten eine erste Vorhersage damit aus:
"""

# ╔═╡ 65d13d96-0e40-4ed7-a2d1-48dea9b64f73
predict = model

# ╔═╡ 9fa806da-0855-41ec-b678-b8f34f0d2549
p1 = predict(x_train)

# ╔═╡ 6de299be-a837-4b4f-b1f4-fa02139d08bb
scatter!(plt, x_train[1,:], p1[1, :], mc = :lightgreen, label = "prediction 1")

# ╔═╡ f2feb934-cd5d-4048-83dc-57c697365af6
md"""
... deren Qualität natürlich noch sehr verbesserungswürdig ist!
"""

# ╔═╡ 16bfc9e4-7e3d-4a91-a8d8-a86bc46e1a15
loss(x, y) = Flux.Losses.mse(predict(x), y)

# ╔═╡ 0bae0976-77fe-4a97-ab41-c3ac26700e4d
md"""
Dies zeigt auch die auf diese Daten angewendete Verlustfunktion (= Kostenfunktion) `mse` (mean squared error):
"""

# ╔═╡ da6502b1-74d5-4519-8c4c-aef9d7e97cc6
loss(x_train, y_train)

# ╔═╡ 8df4a85b-2a25-4320-a099-d9de943c8be2
md"""
## Trainieren des Modells
"""

# ╔═╡ de4f8ace-f83c-4dcc-b518-e5580ea150d7
md"""
In Flux wird ein Modell mit hilfe der Funktion `train!` trainiert. Sie benötigt einen Optimierer (in diesem Fall verwenden wir *gradient descent*: `Descent()`), eine Verlustfunktion (hier: die auf `mse` basierende `loss`-Funktion) sowie natürlich die Trainingsdaten (`x_train` und `y_train`).

Ein weiterer Parameter von `train!` sind sämtliche Parameter des Modells (im vorliegenden, einfachen Beispiel nur `predict.weight` und `predict.bias`), die durch den Trainingsschritt optimiert werden sollen.
"""

# ╔═╡ 2f430d51-37d5-4d81-a9e3-bcc68850917c
opt = Descent()

# ╔═╡ 11e8f05d-3fd6-4646-bf1e-bc8b9437ad3d
train_data = [(x_train, y_train)]

# ╔═╡ 49971f12-dc63-4875-a9d3-af3bf7acccac
(predict.weight, predict.bias)

# ╔═╡ 5fd78586-ab43-4215-8695-9d95d4b081b9
parameters = Flux.params(predict)

# ╔═╡ 88315eeb-51cd-4beb-85ae-0114b91a6cf0
md"""
### Ein erster Trainingsschritt ...
"""

# ╔═╡ 729ecccd-7f4c-4b58-bc8f-0ba6cef340fe
# ╠═╡ skip_as_script = true
#=╠═╡
train!(loss, parameters, train_data, opt)
  ╠═╡ =#

# ╔═╡ bff1a1bc-54c6-499f-83d7-0ceedff1b908
md"""
Der Verlust wurde durch diesen Trainingsschritt tatsächlich kleiner:
"""

# ╔═╡ 1d8d35cb-4f91-42b5-b29d-df81c61ef507
# ╠═╡ skip_as_script = true
#=╠═╡
loss(x_train, y_train)
  ╠═╡ =#

# ╔═╡ 1a68eb65-8ecc-4264-bc3c-c11b37a710d5
md"""
... und offensichtlich haben sich die Modell-Parameter geändert:
"""

# ╔═╡ 8fe85d75-7362-43f5-8085-7b7dd4c786ad
# ╠═╡ skip_as_script = true
#=╠═╡
parameters
  ╠═╡ =#

# ╔═╡ 02e1a9ed-f745-4a27-b844-ef06c2fee8bd
md"""
Auch in der Grafik wird die verbesserte Vorhersage sichtbar:
"""

# ╔═╡ 54c4c3bd-7a76-4d0a-b81b-1c5b4c97a988
# ╠═╡ skip_as_script = true
#=╠═╡
p2 = predict(x_train)
  ╠═╡ =#

# ╔═╡ 22f40cd3-bf88-42ac-8d26-50288597c81a
# ╠═╡ skip_as_script = true
#=╠═╡
scatter!(plt, x_train[1,:], p2[1, :], 
	mc = :green, alpha = 0.5, label = "prediction 2")
  ╠═╡ =#

# ╔═╡ f03c9e14-3249-4959-9f39-994d5635a733
md"""
### ... einige Trainingsschritte mehr
"""

# ╔═╡ 05ec3f23-a43d-45c6-a974-3b8951c83155
# ╠═╡ skip_as_script = true
#=╠═╡
for epoch in 1:200
	train!(loss, parameters, train_data, opt)
end
  ╠═╡ =#

# ╔═╡ 6f70aecc-0b0a-440f-ae70-370dd6f3d4cc
# ╠═╡ skip_as_script = true
#=╠═╡
loss(x_train, y_train)
  ╠═╡ =#

# ╔═╡ 8840c3df-57e0-49d5-9e57-63e1f296cd19
# ╠═╡ skip_as_script = true
#=╠═╡
parameters
  ╠═╡ =#

# ╔═╡ 3990612d-7682-4246-809c-f4a5628ade89
# ╠═╡ skip_as_script = true
#=╠═╡
p3 = predict(x_train)
  ╠═╡ =#

# ╔═╡ fd4b474c-e1e8-4e01-82a8-b76d90308287
#=╠═╡
scatter!(plt, x_train[1,:], p3[1, :], 
	mc = :green, alpha = 0.9, label = "prediction 3")
  ╠═╡ =#

# ╔═╡ 71551da1-3fc0-4d1c-86f7-8e613ce80d44
md"""
## Validierung mit Hilfe der Testdaten
"""

# ╔═╡ f5186a82-d317-4b12-88b7-f14ef7a8bf11
md"""
Zum Zwecke der Validierung werden nun die Testdaten `x_test` als Basis für eine Vorhersage mit dem trainierten Modell genutzt:
"""

# ╔═╡ 861cf58b-89da-4481-8757-fa5925b7f8ec
# ╠═╡ skip_as_script = true
#=╠═╡
ŷ_test = predict(x_test)
  ╠═╡ =#

# ╔═╡ c535530b-dafb-453c-b133-12c4c5365cd0
# ╠═╡ skip_as_script = true
#=╠═╡
y_test
  ╠═╡ =#

# ╔═╡ b7c0fa04-1baa-402f-8a4a-2f931594bc76
md"""
Schon beim Betrachten der vorhergesagten Zahlenwerte `ŷ_test` und der tatsächlichen Werte `y_test` wird die Güte der Vorhersage deutlich.

Das Ergebnis der Verlustfunktion und die graphische Darstellung bestätigen dies.
"""

# ╔═╡ 63d4dcbf-eecf-447b-ba07-0894d4ce083c
# ╠═╡ skip_as_script = true
#=╠═╡
Flux.Losses.mse(y_test, ŷ_test)
  ╠═╡ =#

# ╔═╡ e418f184-8078-448a-8dee-93a63492e051
# ╠═╡ skip_as_script = true
#=╠═╡
scatter!(plt, x_test[1,:], ŷ_test[1,:], 
	mc = :orange, alpha = 0.9, label = "ŷ_test")
  ╠═╡ =#

# ╔═╡ 2837fa33-5910-4153-89d4-a4d51a648674
md"""
# Ein Modell für Obst
"""

# ╔═╡ 8465d965-363e-4d13-9069-993b63c7324b
md"""
Das vorherige Beispiel war offensichtlich eine lineare Regression, umgesetzt mit den Mitteln von Flux. Ein einzelnes `Dense`-Neuron, bei dem als Aktivierungsfunktion die Identität verwendet wird, entspricht also einem linearen Regressionsmodell.

Die Anzahl der Features entspricht dabei der Anzahl der Eingangsparameter.

Beim Beispiel zur Klassifikation von Äpfeln und Bananen haben wir ein Neuron verwendet, welches die Sigmoid-Funktion als Aktivierungsfunktion nutzten (und somit der logistischen Regression entsprach). Auch dies ist mit den Mitteln von Flux möglich.
"""

# ╔═╡ 35957441-a2b7-4a1d-be4c-38eb0c7aebfe
md"""
## Trainings- und Testdaten

Zur Klassifikation der Früchte hatten wir lediglich ein Feature herangezogen, nämlich den Grünwert des Bilder. Dieser lag beim "Trainingsapfel" bei 0,338 und bei der "Trainingsbanane" bei 0,881. Die "Apfelklasse" hatten den Wert 0, während Bananen der Klasse 1 zugeordnet wurden.
"""

# ╔═╡ f7326cc3-5f44-4c4b-ae03-7dfa3ea50716
fruit_x_train, fruit_y_train = [0.338  0.881], [0 1]

# ╔═╡ 0ad591d5-17a9-4ed9-8412-3e51ea5b4d7a
md"""
Als Testdaten hatten wir einen weiteren Apfel und eine weitere Banane. Deren Grünwerte lagen bei 0,469 bzw. 0,807.
"""

# ╔═╡ b172ca0b-663a-4b70-9162-60275b6b8cf3
fruit_x_test, fruit_y_test = [0.469  0.807], [0 1]

# ╔═╡ 12760519-8251-4840-acbd-a424221b16dc
md"""
## Das Modell
"""

# ╔═╡ f1b109af-9504-440a-bd5a-6782ec291991
md"""
Das Modell zur Klassifikation der Obstsorten basierte auf der Sigmoid-Funktion. Dies lässt sich auch in Flux realisieren, wo diese Funktion als eine mögliche Aktivierungsfunktion schon unter dem Namen `sigmoid` vordefiniert ist.
"""

# ╔═╡ 905d8425-9673-4238-8fbe-ff857f5cdd83
predict_fruit = Dense(1 => 1, sigmoid)

# ╔═╡ fc5656aa-169b-4036-93e9-d3ea5c471bd1
predict_fruit.weight

# ╔═╡ 015001de-d780-4440-982a-0e9e28255ad7
predict_fruit.bias

# ╔═╡ 06274fcd-ee69-4966-9f03-9e89edf44421
md"""
### Sigmoid als Aktivierungfunktion
"""

# ╔═╡ a854e50a-a377-40d7-b3e9-6dc0cf3e6d7a
md"""
Um zu zeigen, dass es sich bei `sigmoid` wirklich um die Funktion aus dem Obstbeispiel handelt, hier ein Vergleich der beiden:
"""

# ╔═╡ 8ce5fa74-1b47-46ab-8732-29c3ed6c82cd
σ(x, w, b) = 1 / (1 + exp(-w * x - b))

# ╔═╡ 76a115fe-3643-428d-afb1-96313876de34
md"""
!!! hinweis
    Im Obst-Beispiel wurde als Aktivierungsfunktion $\sigma(x) = \frac{1}{1 + e^{(-wx + b)}}$ verwendet. Setzt man allerdings in die Sigmoid-Funktion den linearen Term $wx + b$ ein, erhält man $\sigma(x) = \frac{1}{1 + e^{(-wx - b)}}$ (d.h. der Bias wird subtrahiert). Diese Variante ist üblicher und wird auch hier benutzt.
"""

# ╔═╡ 5dbad758-e95e-4a1c-924b-b16adad87ccf
md"""
Mit identischer Parametrisierung wird der Funktionswert für 1.0 berechnet:
"""

# ╔═╡ 97409436-f52d-4a6b-8197-7cc2e592e919
σ(1.0, predict_fruit.weight[1,1], predict_fruit.bias[1])

# ╔═╡ 19b7644a-5c5e-4387-91c6-1d70c5ebdcd4
predict_fruit([1.0])

# ╔═╡ 85e629a2-9011-4a55-a2d7-fcc57b27a187
md"""
### Verlustfunktion: Log-Likelihood
"""

# ╔═╡ 425ff10e-e5d9-45ba-9f06-238a5fcad319
md"""
Wenn die Sigmoid-Funktion als Aktivierungsfunktion verwendet wird, nutzt man nicht mehr *mean squared error* zur Berechnung der Verlustfunktion, sondern die *Likelihood-* bzw. die *Log-Likelihood-*Funktion:

$L(\hat{y}, y) = \prod_i^m (1 - \hat{y}^i)^{1 - y^i} \times (\hat{y}^i)^{y^i}$

$l(\hat{y}, y) = \sum_i^m (1 - y^i) \times log{(1 - \hat{y}^i)} + y^i \times log{(\hat{y}^i)}$

Damit erreicht man, dass die Verlustfunktion keine lokalen Maxima hat und mit Hilfe des *Gradient **A**scent*-Verfahrens das Maximum problemlos ermittelt werden kann.

!!! hinweis
    Die Likelihood-Funktion ist eigentlich eine Funktion, die von den Parametern $\Theta$, nicht von den Daten des Modells abhängig ist. Bei den in der obigen Darstellung verwendeten Argumenten $\hat{y}$ und $y$ ist $y$ fix und $\hat{y}$ verändert sich nur, da die Parameter `weight` und `bias` des Modells verändert werden. Tatsächlich ist $L$ also eine Funktion in Abhängigkeit von `weight` und `bias`.

Da in Flux kein Optimierer für das *Gradient Ascent*-Verfahren vordefiniert ist, wird einfach der negative Wert der *Log-Likelihood*-Funktion (der *Minus Log Likelihood*) mit Hilfe des *Gradient Descent* minimiert.
"""

# ╔═╡ 80d8d992-ace4-4165-a42f-f846aacd8811
minus_loglikelihood(ŷ , y, ϵ = eps()) =
	-sum([(1 - yᵢ) * log(1 - ŷᵢ + ϵ) + yᵢ * log(ŷᵢ + ϵ) for (ŷᵢ, yᵢ) in zip(ŷ, y)])

# ╔═╡ e33d877e-0f15-4680-8d22-af921dec5fe9
md"""
Falls das Modell für bestimmte Werte exakt $1.0$ für die Klasse $0$ bzw. exakt $0.0$ für die Klasse $1$ vorhersagt (also eine völlige Fehlklassifikation liefert), werden die Logarithmen des *Log Likelihood* unendlich. Um diesen Fall zu vermeiden, wird ein *Laplace smoothing* mit Hilfe des kleinesten Darstellbaren Gleitkommawerts (dieser wird von der Funktion `eps` geliefert) durchgeführt.
"""

# ╔═╡ 3496a7ec-9c96-4739-bf85-48bc755d4fda
md"""
Auf Basis der `minus_loglikelihood` wird (analog zum Beispiel oben) die Verlustfunktion definiert. Beide Funktionen erwarten $1 \times n$-Matrizen als Parameter.
"""

# ╔═╡ 5b813976-8677-408e-8c11-1450a93f677f
fruit_loss(x, y) = minus_loglikelihood(predict_fruit(x), y)

# ╔═╡ a9be2641-46fb-47ff-a4ec-04aa938dfe24
md"""
Beispiele zur Demonstration der Argumenttypen:
"""

# ╔═╡ 5212170d-c03a-45fd-8856-8da6e63956bf
fruit_loss([1,2,3]', [0,1,0]')

# ╔═╡ a931e554-9336-4e26-a7e1-36d33869e47f
minus_loglikelihood(predict_fruit([1 2 3]) , [0 1 0])

# ╔═╡ 149c15a2-70b1-4f5c-ad76-32dd86961868
md"""
### Trainieren
"""

# ╔═╡ b577e283-50df-4166-91a2-1e3746d696c8
md"""
Für die Übergabe an die `train!`-Funktion müssen die Trainingsdaten wieder entsprechend 'verpackt' werden:
"""

# ╔═╡ 5bf2bfbc-ea5d-45bb-80f6-9bc6d9138959
fruit_data = [(fruit_x_train, fruit_y_train)]

# ╔═╡ 76dc368d-e355-4d0c-a132-55a8505db390
fruit_parameters = Flux.params(predict_fruit)

# ╔═╡ eef371f5-b54a-4fec-9c1d-862ec84a1bab
md"""
Nachdem alle Vorbereitungen getroffen wurden, kann das Modell nun iterativ optimiert werden.
"""

# ╔═╡ 9494c792-903e-43f3-a9ed-959831c2cf5b
# ╠═╡ skip_as_script = true
#=╠═╡
for epoch in 1:100
	train!(fruit_loss, fruit_parameters, fruit_data, opt)
end
  ╠═╡ =#

# ╔═╡ 9dee2bc3-ac5d-4051-a6e4-b29aafd44d09
md"""
## Ergebnisse
"""

# ╔═╡ fc88ab0e-edab-4d00-8518-5f471b146484
md"""
Und offensichtlich wurden dadurch die Modell-Parameter verändert und der Wert der Verlustfunktion deutlich reduziert:
"""

# ╔═╡ 33a22730-be60-4e12-99d7-cd66262f2a29
# ╠═╡ skip_as_script = true
#=╠═╡
fruit_parameters
  ╠═╡ =#

# ╔═╡ f772c36e-1018-4172-8959-88cacf94e310
# ╠═╡ skip_as_script = true
#=╠═╡
pf1 = predict_fruit(fruit_x_train)
  ╠═╡ =#

# ╔═╡ 575b4836-f6d1-471b-be94-806369ad4b91
# ╠═╡ skip_as_script = true
#=╠═╡
fruit_loss(fruit_x_train, fruit_y_train)
  ╠═╡ =#

# ╔═╡ 49fbb795-eab5-4c92-8d67-dc7ee29f61ce
md"""
Die resultierende Funktion wird nun visualisiert und es wird gezeigt, wie gut die Trainingsdaten "getroffen" wurden:
"""

# ╔═╡ 29daacc5-0c83-49f7-800f-be439dca774e
range = -1.0:0.01:1.5

# ╔═╡ 26139cd2-149c-4574-88e8-fce4cb6ac918
pred = predict_fruit(range')

# ╔═╡ 9a25fbcf-c914-457e-b9eb-885b00bf520b
# ╠═╡ skip_as_script = true
#=╠═╡
fplt = plot(range, pred[1,:], leg = :outerright, label = "fruit model")
  ╠═╡ =#

# ╔═╡ 6e9d6e23-5878-4533-bd20-42a233d7f49b
# ╠═╡ skip_as_script = true
#=╠═╡
scatter!(fplt, fruit_x_train, fruit_y_train, labels = ["apple" "banana"])
  ╠═╡ =#

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Flux = "587475ba-b771-5e3f-ad9e-33799f191a9c"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Flux = "~0.13.15"
Plots = "~1.38.11"
PlutoUI = "~0.7.51"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "8ccf7a9e878b32a9b53460a618734e2e8e58cb97"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "16b6dbc4cf7caee4e1e75c49485ec67b667098a0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.3.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Accessors]]
deps = ["Compat", "CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Requires", "StaticArrays", "Test"]
git-tree-sha1 = "c7dddee3f32ceac12abd9a21cd0c4cb489f230d2"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.29"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cc37d689f599e8df4f464b2fa3870ff7db7492ef"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.1"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Atomix]]
deps = ["UnsafeAtomics"]
git-tree-sha1 = "c06a868224ecba914baa6942988e2f2aade419be"
uuid = "a9b6321e-bd34-4604-b9c9-b65b8de01458"
version = "0.1.0"

[[deps.BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "dbf84058d0a8cbbadee18d25cf606934b22d7c66"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.4.2"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "Future", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables", "ZygoteRules"]
git-tree-sha1 = "7fe6d92c4f281cf4ca6f2fba0ce7b299742da7ca"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.37"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CUDA_Driver_jll", "CUDA_Runtime_Discovery", "CUDA_Runtime_jll", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "KernelAbstractions", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Preferences", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "280893f920654ebfaaaa1999fbd975689051f890"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "4.2.0"

[[deps.CUDA_Driver_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "498f45593f6ddc0adff64a9310bb6710e851781b"
uuid = "4ee394cb-3365-5eb0-8335-949819d2adfc"
version = "0.5.0+1"

[[deps.CUDA_Runtime_Discovery]]
deps = ["Libdl"]
git-tree-sha1 = "bcc4a23cbbd99c8535a5318455dcf0f2546ec536"
uuid = "1af6417a-86b4-443c-805f-a4643ffb695f"
version = "0.2.2"

[[deps.CUDA_Runtime_jll]]
deps = ["Artifacts", "CUDA_Driver_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "5248d9c45712e51e27ba9b30eebec65658c6ce29"
uuid = "76a88914-d11a-5bdc-97e0-2f5a05c973a2"
version = "0.6.0+0"

[[deps.CUDNN_jll]]
deps = ["Artifacts", "CUDA_Runtime_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "2918fbffb50e3b7a0b9127617587afa76d4276e8"
uuid = "62b44479-cb7b-5706-934f-f13b2eb2e645"
version = "8.8.1+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRules]]
deps = ["Adapt", "ChainRulesCore", "Compat", "Distributed", "GPUArraysCore", "IrrationalConstants", "LinearAlgebra", "Random", "RealDot", "SparseArrays", "Statistics", "StructArrays"]
git-tree-sha1 = "8bae903893aeeb429cf732cf1888490b93ecf265"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.49.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "f84967c4497e0e1955f9a582c232b02847c5f589"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "be6ab11021cd29f0344d5c4357b163af05a48cba"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.21.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "455419f7e328a1a2493cabc6428d79e951349769"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "b306df2650947e9eb100ec125ff8c65ca2053d30"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.1.1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "89a9db8d28102b094992472d333674bd1a83ce2a"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.1"

[[deps.ContextVariablesX]]
deps = ["Compat", "Logging", "UUIDs"]
git-tree-sha1 = "25cc3803f1030ab855e383129dcd3dc294e322cc"
uuid = "6add18c4-b38d-439d-96f6-d6bc489c04c5"
version = "0.1.3"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "a4ad7ef19d2cdc2eff57abbbe68032b1cd0bd8f8"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.13.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.ExprTools]]
git-tree-sha1 = "c1d06d129da9f55715c6c212866f5b1bddc5fa00"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.9"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FLoops]]
deps = ["BangBang", "Compat", "FLoopsBase", "InitialValues", "JuliaVariables", "MLStyle", "Serialization", "Setfield", "Transducers"]
git-tree-sha1 = "ffb97765602e3cbe59a0589d237bf07f245a8576"
uuid = "cc61a311-1640-44b5-9fba-1b764f453329"
version = "0.2.1"

[[deps.FLoopsBase]]
deps = ["ContextVariablesX"]
git-tree-sha1 = "656f7a6859be8673bf1f35da5670246b923964f7"
uuid = "b9860ae5-e623-471e-878b-f6a53c775ea6"
version = "0.1.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "fc86b4fd3eff76c3ce4f5e96e2fdfa6282722885"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.0.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Flux]]
deps = ["Adapt", "CUDA", "ChainRulesCore", "Functors", "LinearAlgebra", "MLUtils", "MacroTools", "NNlib", "NNlibCUDA", "OneHotArrays", "Optimisers", "Preferences", "ProgressLogging", "Random", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "Zygote", "cuDNN"]
git-tree-sha1 = "3f6f32ec0bfd80be0cb65907cf74ec796a632012"
uuid = "587475ba-b771-5e3f-ad9e-33799f191a9c"
version = "0.13.15"

[[deps.FoldsThreads]]
deps = ["Accessors", "FunctionWrappers", "InitialValues", "SplittablesBase", "Transducers"]
git-tree-sha1 = "eb8e1989b9028f7e0985b4268dabe94682249025"
uuid = "9c68100b-dfe1-47cf-94c8-95104e173443"
version = "0.1.1"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "00e252f4d706b3d55a8863432e742bf5717b498d"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.35"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.FunctionWrappers]]
git-tree-sha1 = "d62485945ce5ae9c0c48f124a84998d755bae00e"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.3"

[[deps.Functors]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "478f8c3145bb91d82c2cf20433e8c1b30df454cc"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.4.4"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GPUArrays]]
deps = ["Adapt", "GPUArraysCore", "LLVM", "LinearAlgebra", "Printf", "Random", "Reexport", "Serialization", "Statistics"]
git-tree-sha1 = "9ade6983c3dbbd492cf5729f865fe030d1541463"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.6.6"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "1cd7f0af1aa58abc02ea1d872953a97359cb87fa"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.4"

[[deps.GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "Scratch", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "e9a9173cd77e16509cdf9c1663fda19b22a518b7"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.19.3"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "efaac003187ccc71ace6c755b197284cd4811bfe"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.4"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4486ff47de4c18cb511a0da420efebb314556316"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.4+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "69182f9a2d6add3736b7a06ab6416aafdeec2196"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.8.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "0ade27f0c49cebd8db2523c4eeccf779407cf12c"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.9"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "6667aadd1cdee2c6cd068128b3d226ebc4fb0c67"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.9"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.JuliaVariables]]
deps = ["MLStyle", "NameResolution"]
git-tree-sha1 = "49fb3cb53362ddadb4415e9b73926d6b40709e70"
uuid = "b14d175d-62b4-44ba-8fb7-3064adc8c3ec"
version = "0.2.4"

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "LinearAlgebra", "MacroTools", "PrecompileTools", "SparseArrays", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "47be64f040a7ece575c2b5f53ca6da7b548d69f4"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.9.4"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "a8960cae30b42b66dd41808beb76490519f6f9e2"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "5.0.0"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "09b7505cc0b1cee87e5d4a26eea61d2e1b0dcd35"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.21+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "099e356f267354f46ba65087981a77da23a279b7"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[deps.MLUtils]]
deps = ["ChainRulesCore", "Compat", "DataAPI", "DelimitedFiles", "FLoops", "FoldsThreads", "NNlib", "Random", "ShowCases", "SimpleTraits", "Statistics", "StatsBase", "Tables", "Transducers"]
git-tree-sha1 = "ca31739905ddb08c59758726e22b9e25d0d1521b"
uuid = "f1d291b0-491e-4a28-83b9-f70985020b54"
version = "0.4.2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "629afd7d10dbc6935ec59b32daeb33bc4460a42e"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.4"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NNlib]]
deps = ["Adapt", "Atomix", "ChainRulesCore", "GPUArraysCore", "KernelAbstractions", "LinearAlgebra", "Pkg", "Random", "Requires", "Statistics"]
git-tree-sha1 = "99e6dbb50d8a96702dc60954569e9fe7291cc55d"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.8.20"

[[deps.NNlibCUDA]]
deps = ["Adapt", "CUDA", "LinearAlgebra", "NNlib", "Random", "Statistics", "cuDNN"]
git-tree-sha1 = "f94a9684394ff0d325cc12b06da7032d8be01aaf"
uuid = "a00861dc-f156-4864-bf3c-e6376f28a68d"
version = "0.2.7"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NameResolution]]
deps = ["PrettyPrint"]
git-tree-sha1 = "1a0fa0e9613f46c9b8c11eee38ebb4f590013c5e"
uuid = "71a1bf82-56d0-4bbc-8a3c-48b961074391"
version = "0.1.5"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OneHotArrays]]
deps = ["Adapt", "ChainRulesCore", "Compat", "GPUArraysCore", "LinearAlgebra", "NNlib"]
git-tree-sha1 = "f511fca956ed9e70b80cd3417bb8c2dde4b68644"
uuid = "0b1bfda6-eb8a-41d2-88d8-f5af5cad476f"
version = "0.2.3"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "7fb975217aea8f1bb360cf1dde70bad2530622d2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ff31d101d987eb9d66bd8b176ac7c277beccd09"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.20+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Optimisers]]
deps = ["ChainRulesCore", "Functors", "LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "6a01f65dd8583dee82eecc2a19b0ff21521aa749"
uuid = "3bd65402-5787-11e9-1adc-39752487f4e2"
version = "0.2.18"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "6c7f47fd112001fc95ea1569c2757dffd9e81328"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.11"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "b478a748be27bd2f2c73a7690da219d0844db305"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.51"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "d0984cc886c48e5a165705ce65236dc2ec467b91"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "552f30e847641591ba3f39fd1bed559b9deb0ef3"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.6.1"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.ShowCases]]
git-tree-sha1 = "7f534ad62ab2bd48591bdeac81994ea8c445e4a5"
uuid = "605ecd9f-84a6-4c9e-81e2-4798472b76a3"
version = "0.1.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "ef28127915f4229c971eb43f3fc075dd3fe91880"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.2.0"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "c262c8e978048c2b095be1672c9bee55b4619521"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.24"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "521a0e828e98bb69042fec1809c1b5a680eb7389"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.15"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f548a9e9c490030e545f72074a41edfd0e5bcdd7"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.23"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "c42fa452a60f022e9e087823b47e5a5f8adc53d5"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.75"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "ea37e6066bf194ab78f4e747f5245261f17a7175"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.1.2"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "GPUArrays", "GPUArraysCore", "IRTools", "InteractiveUtils", "LinearAlgebra", "LogExpFunctions", "MacroTools", "NaNMath", "Random", "Requires", "SnoopPrecompile", "SparseArrays", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "987ae5554ca90e837594a0f30325eeb5e7303d1e"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.60"

[[deps.ZygoteRules]]
deps = ["ChainRulesCore", "MacroTools"]
git-tree-sha1 = "977aed5d006b840e2e40c0b48984f7463109046d"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.3"

[[deps.cuDNN]]
deps = ["CEnum", "CUDA", "CUDNN_jll"]
git-tree-sha1 = "ec954b59f6b0324543f2e3ed8118309ac60cb75b"
uuid = "02a925ec-e4fe-4b08-9a7e-0d78e3d38ccd"
version = "1.0.3"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─7e63fbb7-5260-463a-9e8d-dea6b3bf3ed4
# ╟─5b9e0eda-ba4c-11ec-05c8-07ccdc39ccb8
# ╟─f4f96036-a408-43c7-a481-70c125dbd144
# ╟─63bfcfd4-8597-4b2f-b7de-61058f39d6c7
# ╟─933de385-f043-4e0d-9a78-61b7f63e048a
# ╟─a3280ef2-7317-49a6-8f81-2fd9440a0b3b
# ╟─175abc83-7996-4ec3-82bd-d58a72de6f6d
# ╟─c39a00c7-43ad-4b83-8741-c776eead3ae8
# ╟─2647373e-49f3-45ce-84c1-c5adb96a0545
# ╟─04440986-406a-4793-9e92-eb775de23495
# ╠═30545456-fb29-498a-85db-3d842edaf550
# ╟─dc461f63-b8e7-4055-9e98-62228d29f4f0
# ╠═1c5b8847-9da1-4808-8fe5-9075450d3ab5
# ╟─1bca5c8f-15c3-43ee-af90-40657e6f64f4
# ╠═150ca9bf-1dc0-4889-a272-8a8a31a8c345
# ╟─01e41b40-5858-4fd8-8794-bb5009fb4232
# ╠═a59df77e-c280-4eef-8485-816a8afc6fac
# ╠═a2441e17-e25d-4656-8382-86a8c5aec4f1
# ╟─33a91ebe-1d0d-4331-a46c-a49bbd6229bf
# ╠═4f597419-eec8-43b0-a9de-f9264640109d
# ╟─91b8f6a6-5cf5-4a70-817d-346dc6d9fa36
# ╠═cae3ac1c-4cb2-4e9e-ac3f-f562040eea35
# ╟─5918ddd9-e67b-46e4-8a60-31868857036b
# ╠═0e969a60-2290-4d82-b99d-450142327594
# ╟─f5b45a25-70b7-41a1-90c0-476fa8d693df
# ╟─c262f6a3-8df6-41f6-83de-bc7874dfd4a8
# ╟─7579db47-61f6-46c0-994f-5885a5887aab
# ╠═1b9aac58-dc41-4ade-9704-b994bf9d39cd
# ╟─c1dc7783-cdda-4197-830a-93149f516df3
# ╟─fef5f51a-c126-4d9b-9b91-178ce42987e6
# ╠═2fa9aab2-73af-434d-9ed5-79c127ee473b
# ╟─d0ae088b-c03d-4693-8e82-df84b4bb5e4a
# ╠═bd1d519c-dcd9-48d1-a25e-e7bed79b6ca8
# ╟─fa1e8df6-c040-4694-b747-f87377594616
# ╟─b8193edf-9b8a-4020-a04f-3683a0350825
# ╟─148f4f27-22ef-495f-b702-b1cb056a6ac5
# ╟─c33ab974-e8ea-4534-b47a-328e9a393ead
# ╟─1b938c7e-43c2-4d99-9db5-09cd9b52d4d7
# ╠═b5b4783b-7b6f-48d7-9576-42bf104e6886
# ╠═816a7308-e11b-407b-91f9-719c139cd4ff
# ╟─788c8387-075d-4f09-9250-f9e62051e42b
# ╟─4ff17862-19cc-4d9d-aa09-ad40830bbffa
# ╠═65d13d96-0e40-4ed7-a2d1-48dea9b64f73
# ╠═9fa806da-0855-41ec-b678-b8f34f0d2549
# ╟─6de299be-a837-4b4f-b1f4-fa02139d08bb
# ╟─f2feb934-cd5d-4048-83dc-57c697365af6
# ╠═16bfc9e4-7e3d-4a91-a8d8-a86bc46e1a15
# ╟─0bae0976-77fe-4a97-ab41-c3ac26700e4d
# ╠═da6502b1-74d5-4519-8c4c-aef9d7e97cc6
# ╟─8df4a85b-2a25-4320-a099-d9de943c8be2
# ╟─de4f8ace-f83c-4dcc-b518-e5580ea150d7
# ╠═9171f9b1-b139-4408-8d9d-186ffb0819b0
# ╠═2f430d51-37d5-4d81-a9e3-bcc68850917c
# ╠═11e8f05d-3fd6-4646-bf1e-bc8b9437ad3d
# ╠═49971f12-dc63-4875-a9d3-af3bf7acccac
# ╠═5fd78586-ab43-4215-8695-9d95d4b081b9
# ╟─88315eeb-51cd-4beb-85ae-0114b91a6cf0
# ╠═729ecccd-7f4c-4b58-bc8f-0ba6cef340fe
# ╟─bff1a1bc-54c6-499f-83d7-0ceedff1b908
# ╠═1d8d35cb-4f91-42b5-b29d-df81c61ef507
# ╟─1a68eb65-8ecc-4264-bc3c-c11b37a710d5
# ╠═8fe85d75-7362-43f5-8085-7b7dd4c786ad
# ╟─02e1a9ed-f745-4a27-b844-ef06c2fee8bd
# ╠═54c4c3bd-7a76-4d0a-b81b-1c5b4c97a988
# ╠═22f40cd3-bf88-42ac-8d26-50288597c81a
# ╟─f03c9e14-3249-4959-9f39-994d5635a733
# ╠═05ec3f23-a43d-45c6-a974-3b8951c83155
# ╠═6f70aecc-0b0a-440f-ae70-370dd6f3d4cc
# ╠═8840c3df-57e0-49d5-9e57-63e1f296cd19
# ╠═3990612d-7682-4246-809c-f4a5628ade89
# ╟─fd4b474c-e1e8-4e01-82a8-b76d90308287
# ╟─71551da1-3fc0-4d1c-86f7-8e613ce80d44
# ╟─f5186a82-d317-4b12-88b7-f14ef7a8bf11
# ╠═861cf58b-89da-4481-8757-fa5925b7f8ec
# ╠═c535530b-dafb-453c-b133-12c4c5365cd0
# ╟─b7c0fa04-1baa-402f-8a4a-2f931594bc76
# ╠═63d4dcbf-eecf-447b-ba07-0894d4ce083c
# ╠═e418f184-8078-448a-8dee-93a63492e051
# ╟─2837fa33-5910-4153-89d4-a4d51a648674
# ╟─8465d965-363e-4d13-9069-993b63c7324b
# ╟─35957441-a2b7-4a1d-be4c-38eb0c7aebfe
# ╠═f7326cc3-5f44-4c4b-ae03-7dfa3ea50716
# ╟─0ad591d5-17a9-4ed9-8412-3e51ea5b4d7a
# ╠═b172ca0b-663a-4b70-9162-60275b6b8cf3
# ╟─12760519-8251-4840-acbd-a424221b16dc
# ╟─f1b109af-9504-440a-bd5a-6782ec291991
# ╠═905d8425-9673-4238-8fbe-ff857f5cdd83
# ╠═fc5656aa-169b-4036-93e9-d3ea5c471bd1
# ╠═015001de-d780-4440-982a-0e9e28255ad7
# ╟─06274fcd-ee69-4966-9f03-9e89edf44421
# ╟─a854e50a-a377-40d7-b3e9-6dc0cf3e6d7a
# ╠═8ce5fa74-1b47-46ab-8732-29c3ed6c82cd
# ╟─76a115fe-3643-428d-afb1-96313876de34
# ╟─5dbad758-e95e-4a1c-924b-b16adad87ccf
# ╠═97409436-f52d-4a6b-8197-7cc2e592e919
# ╠═19b7644a-5c5e-4387-91c6-1d70c5ebdcd4
# ╟─85e629a2-9011-4a55-a2d7-fcc57b27a187
# ╟─425ff10e-e5d9-45ba-9f06-238a5fcad319
# ╠═80d8d992-ace4-4165-a42f-f846aacd8811
# ╟─e33d877e-0f15-4680-8d22-af921dec5fe9
# ╟─3496a7ec-9c96-4739-bf85-48bc755d4fda
# ╠═5b813976-8677-408e-8c11-1450a93f677f
# ╟─a9be2641-46fb-47ff-a4ec-04aa938dfe24
# ╠═5212170d-c03a-45fd-8856-8da6e63956bf
# ╠═a931e554-9336-4e26-a7e1-36d33869e47f
# ╟─149c15a2-70b1-4f5c-ad76-32dd86961868
# ╟─b577e283-50df-4166-91a2-1e3746d696c8
# ╠═5bf2bfbc-ea5d-45bb-80f6-9bc6d9138959
# ╠═76dc368d-e355-4d0c-a132-55a8505db390
# ╟─eef371f5-b54a-4fec-9c1d-862ec84a1bab
# ╠═9494c792-903e-43f3-a9ed-959831c2cf5b
# ╟─9dee2bc3-ac5d-4051-a6e4-b29aafd44d09
# ╟─fc88ab0e-edab-4d00-8518-5f471b146484
# ╠═33a22730-be60-4e12-99d7-cd66262f2a29
# ╠═f772c36e-1018-4172-8959-88cacf94e310
# ╠═575b4836-f6d1-471b-be94-806369ad4b91
# ╟─49fbb795-eab5-4c92-8d67-dc7ee29f61ce
# ╠═29daacc5-0c83-49f7-800f-be439dca774e
# ╠═26139cd2-149c-4574-88e8-fce4cb6ac918
# ╠═9a25fbcf-c914-457e-b9eb-885b00bf520b
# ╠═6e9d6e23-5878-4533-bd20-42a233d7f49b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
