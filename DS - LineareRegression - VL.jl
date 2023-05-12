### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 3aa2e730-9222-11eb-0fed-97fb58900add
begin
	using DataFrames
	using PlutoUI
	using ForwardDiff
	using Plots
    using MLJ
    import MLJLinearModels
	import MLJMultivariateStatsInterface
end

# ╔═╡ c9fa8be0-8e79-41ee-ab3d-79f06bca89ef
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
">Data Science & Machine Learning</p>
<p style="text-align: left; font-size: 2.8rem;">
Lineare Regression
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

# ╔═╡ 670200e0-9222-11eb-0c7f-bd86735f1dca
PlutoUI.TableOfContents(title = "Lineare Regression")

# ╔═╡ bd64ecac-1e8e-42a6-a8e2-cce2394907f9
html"<button onclick='present()'>present</button>"

# ╔═╡ e22e4a80-9222-11eb-2477-69c243a6f614
md"""
# Verfahren im Überblick
Der Klassiker schlechthin unter den linearen Modellen ist die lineare Regression. Es handelt sich um ein Modell, welches seine Anwendung bei rein *numerischen Daten* findet. D.h. sowohl die Attribute als auch die “Klasse” zu der eine Instanz gehört, sind numerisch.

Bei der linearen Regression geht man davon aus, dass für jede Instanz $I_i$ mit den Attributwerten $a^{(i)}_1, \dots, a^{(i)}_n, (1 \le i \le n)$, die zu einer Klasse $y^{(i)}$ gehört,  Gewichte $w_0, w_1, \dots, w_n$ gefunden werden können, so dass die Klasse $y^{(i)}$ wie folgt ermittelt (”vorhergesagt”) werden kann:

$$y^{(i)} = w_0 + w_1 a^{(i)}_1 + \dots + w_n a^{(i)}_n \quad \textrm{(Gl. 1)}$$

Ein derartiger Zusammenhang besteht nur, wenn zwischen den Attributwerten und der davon abhängigen Klasse eine starke Korrelation besteht. Nur dann ist die Anwendung der linearen Regression sinnvoll.
"""

# ╔═╡ 73292490-922a-11eb-2593-1b967f05f295
md"""
## Darstellung im zweidimensionalen Fall 

Für $n = 1$ hat man den zweidimensionalen Fall, der graphisch gut veranschaulicht werden kann. Die Instanzen $I_i$ sind dann Tupel der Form $(a^{(i)}_1, y^{(i)})$.

Ob die Daten, wie oben beschreiben, entsprechend korreliert sind, kann man hier gut erkennen, wenn man die Daten mit Hilfe eines sog. Streudiagramms (engl. Scatterplot) darstellt.
"""

# ╔═╡ b08f4770-9224-11eb-0bfc-4516f3638ce0
@bind m Slider(10:30, default = 21, show_value = true)

# ╔═╡ 958c57a2-9225-11eb-268f-a7bfdfeeab55
md"""
m = $(m)
"""

# ╔═╡ c6033920-9249-11eb-2e66-e178b76f56c8
md"""
In einer idealen Welt würden alle Datenpunkte wie in folgendem Diagramm auf einer Geraden liegen:
"""

# ╔═╡ 818706c0-9224-11eb-0701-03fc802f08b1
begin
	ideal_a₁ = [x for x = range(0, 20, length = m)]
	ideal_y = [0.8x for x in ideal_a₁]
	scatter(ideal_a₁, ideal_y, leg = false)
end

# ╔═╡ 26955c50-924a-11eb-3b47-b7bb5b76b02d
md"""
Bei realen Daten ist dies selten der Fall. Aber auch in einer solchen Situation erkennt man mittels eines Scatterplots, ob die Daten tendenziell durch eine Gerade angenähert werden können (und die lineare Regression somit Sinn macht):
"""

# ╔═╡ e55f10e0-924a-11eb-1f35-3f1de0285f57
@bind noiseFactor Slider(0.0:10.0, default = 1.0)

# ╔═╡ 1eb06010-924b-11eb-1f9b-1366e692b8f8
noiseFactor

# ╔═╡ bd601d00-924a-11eb-0826-7db331e2d358
begin
	noiseX = (rand(m) .- 0.5) .* noiseFactor
	noiseY = (rand(m) .- 0.5) .* noiseFactor
	a₁ = ideal_a₁ .+ noiseX
	y = ideal_y .+ noiseY
	scatter(a₁, y, leg = false)
end

# ╔═╡ fc88fa2d-016d-4a63-8157-1d6031edd813
md"""
## Notation

Um eine durchgängige Notation herzustellen, wird die o.g. lineare Gleichung (Gl. 1) typischerweise durch ein künstliches Attribut $a^{(i)}_0$ mit dem Wert 1 ergänzt, so dass sie wie folgt geschrieben werden kann:

$$w_0 a^{(i)}_0 + w_1 a^{(i)}_1 + \dots + w_n a^{(i)}_n = \sum^n_{j=0}w_j a^{(i)}_j  \quad \textrm{(Gl. 2)}$$

Außerdem wurde durch die obige Darstellung deutlich, dass eine lineare Gleichung reale Daten lediglich approximieren, aber nicht exakt voraussagen kann. D.h. die durch Gl. 1 dargestellte Gleichheit kann i.A. nicht hergestellt werden.

Die real beobachteten Klassen werden deshalb mit $y^{(i)}$ bezeichnet, während die von der linearen Gleichung vorhergesagten Werte die Bezeichnung $\hat{y}^{(i)}$ erhalten. Somit ist:

$\hat{y}^{(i)} = \sum^n_{j=0}w_j a^{(i)}_j  \quad \textrm{(Gl. 2´)}$

"""

# ╔═╡ 650948ac-9e2a-462e-ad1d-e343a498c9cf
md"""
# Ermittlung der Gewichte
"""

# ╔═╡ 71b5c600-924c-11eb-3dda-414647679cc4
md"""
## Methode der kleinsten Quadrate

Um nun “optimale” Werte für die Gewichte $w_0, w_1, \dots, w_n$ zu finden, wird die **Methode der kleinsten Quadrate** (*least squares approximation*) angewendet. 

Dabei versucht man den “Abstand” zwischen den durch Gl. 2'  vorhergesagten Klassen $\hat{y}^{(i)}$ und den tatsächlichen Klassen $y^{(i)}$ zu minimieren. Zu diesem Zweck werden die Differenzen zwischen diesen Werten gebildet und deren Quadrate aufsummiert:

$$S(\vec{w}) = \sum^m_{i=1} \left( y^{(i)} - \sum^n_{j=0}w_j a^{(i)}_j \right)^2 \quad \textrm{(Gl. 3)}$$

Zur Ermittlung der Gewichte $\vec{w}$ mit gleichzeitiger Minimierung dieser Kostenfunktion $S(\vec{w})$ gibt es zwei Ansätze:

- Einen geschlossen Ansatz über die [Normalenform](https://de.wikipedia.org/wiki/Normalenform#) und den [Gauß-Jordan-Algorithmus](https://de.wikipedia.org/wiki/Gau%C3%9F-Jordan-Algorithmus). Dieser hat allerdings eine Komplexität von $O(n^3)$. Besser ist die Singulärwertzerlegung (auch [*singular value decomposition, SVD*](https://en.wikipedia.org/wiki/Singular_value_decomposition) genannt) mit einer Komplexität von $O(n^2)$.

- Eine bessere Effizienz (insbesondere bei einer hohen Anzahl von Attributen und Instanzen) erreicht man durch ein Näherungsverfahren, das sog. [Gradient-Descent-Verfahren](https://de.wikipedia.org/wiki/Gradientenverfahren), bei dem unter Nutzung partieller Ableitungen iterativ das Minimum gesucht wird.

"""

# ╔═╡ 45af1a7e-8c92-49d0-aa3c-800b0e4eab60
md"""
Weiterführende Informationen:
- [2 ways to train a Linear Regression Model - Part 1](https://medium.com/analytics-vidhya/2-ways-to-train-a-linear-regression-model-part-1-e643dbef3df1)
- [2 ways to train a Linear Regression Model - Part 2](https://medium.com/analytics-vidhya/2-ways-to-train-a-linear-regression-model-part-2-fdeb50fc58fa)
- [Tutorial: Linear Regression with Stochastic Gradient Descent](https://towardsdatascience.com/step-by-step-tutorial-on-linear-regression-with-stochastic-gradient-descent-1d35b088a843)
- [Einfache lineare Regression](https://www.inwt-statistics.de/blog-artikel-lesen/Einfache_lineare_Regression.html)
- [Lecture 2 - Linear Regresssion and Gradient Descent, Stanford CS229: Maschine Learning (Autumn 2018)](https://youtu.be/4b4MUYve_U8)
"""

# ╔═╡ 580dc9bc-4aca-4d65-ba61-a0e88dbe7b2d
md"""
Außerdem wissenswert:
- Im Kontext der Linearen Regression bezeichnen wir  $w_0, w_1, \dots, w_n$ als *Gewichte*. Allgemein werden solche "Stellschrauben" bei Lernverfahren jeodoch als **Parameter** bezeichnet.
- Das *Gradient-Descent-Verfahren* lässt sich nicht nur bei der Linearen Regression, sondern bei einer ganzen Klasse ähnlich gelagerter Probleme zur Bestimmung der Parameter anwenden. Es hat somit eine wesentliche Bedeutung im Bereich des Machine Learning.

"""

# ╔═╡ ac8bd5b1-3425-48d5-93b6-81dc92819674
md"""
## Vorhersagefehler

Natürlich “trifft” die so ermittelte Gleichung die tatsächlichen Klassen mehr oder weniger gut (d.h. das in Gl. 3 berechnete Abstandsmaß kann i.A. nicht auf 0 reduziert werden). Die Differenz zwischen tatsächlicher Klasse und vorhergesagter Klasse ``y^{(i)} - \hat{y}^{(i)}  = e^{(i)}`` wird **Vorhersagefehler** (oder auch: **Störgröße, Residuum**) genannt (wobei zwischen den letzteren Begriffen noch weiter differenziert wird: [Störgröße und Residuum](https://de.wikipedia.org/wiki/St%C3%B6rgr%C3%B6%C3%9Fe_und_Residuum).

Somit lautet Gl. 1 eigentlich wie folgt:

$$y^{(i)} = \sum^n_{j=0}w_j a^{(i)}_j + e^{(i)} \quad \textrm{(Gl. 1´)}$$
"""

# ╔═╡ aefe9339-c138-4a55-a2fd-b05552e11fcd
md"""
# Gradient Descent
"""

# ╔═╡ ab2a9665-5981-45f6-ba1e-97e12136c492
md"""
Im Folgenden wird gezeigt, wie mittels des Gradient-Descent-Verfahrens iterativ ein guter Näherungswert für die optimalen Gewichte gefunden werden kann.
"""

# ╔═╡ 17d4279e-9254-11eb-16a5-492585246cae
md"""
## Manuelle Ermittlung der Gewichte
"""

# ╔═╡ edde71fd-86a8-4d1c-9379-58f594b722aa
md"""
Die Vorhersagefunktion (Gl. 2') hat für $m = 1$ zwei Gewichte $w_0$ und $w_1$:
"""

# ╔═╡ 28061ece-9254-11eb-1fae-817c58c71708
ŷ(w₀, w₁) = x -> w₀ + w₁ * x 	# Die Vorhersagefunktion

# ╔═╡ bf58b070-8eee-4acf-8aa4-ecc38b2d23b2
md"""
Die Kostenfunktion $S$ (aus Gl. 3) hat als Parameter diese beiden Gewichte sowie die real beobachteten Instanzen $I_i = (a_1^{(i)}, y^{(i)})$, bestehend aus einem Attribut und der zugehörigen Klasse. 
"""

# ╔═╡ 33b93d40-9257-11eb-15f7-bfa73c4ddf08
# Berechnung der Summe der Quadrate zwischen den vorhergesagten Werten 
# aus der Vorhersagefunktion `ŷ(w₀, w₁)` und den tatsächlichen Werten.

function S(w0, w1, X, y)
	qsum = 0.0
	for i in eachindex(X)
		qsum += ( y[i] - ŷ(w0, w1)(X[i]) )^2
	end
	return(qsum)
end

# ╔═╡ 87c19456-dfd7-4740-a172-13c4789120d6
md"""
Durch folgende Schieberegler können die Werte für $w_0$ und $w_1$ variiert werden. Dementsprechend ändert sich der Wert von $S$. Im darunterliegenden Diagramm lässt sich beobachten, wie gut die sich daraus ergebende Gerade die realen Datenpunkte approximiert.
"""

# ╔═╡ c7dc2bf0-9256-11eb-15e0-6f481470beb2
md"""
 $w_0$ = $(@bind w₀ Slider(-1.5:0.1:2, default = 0.0, show_value = true))
"""

# ╔═╡ d5efaff2-9256-11eb-389b-e3bb107f9633
md"""
 $w_1$ = $(@bind w₁ Slider(-1:0.1:1.5, default = 1.0, show_value = true))
"""

# ╔═╡ 2a6e6f70-9258-11eb-1f7a-ed5c7f2e88ed
S(w₀, w₁, a₁, y)

# ╔═╡ d7eed22d-24f9-4533-a5d2-01194d8f2b64
begin
	xvals = 0.0:0.1:20.0
	yvals = ŷ(w₀, w₁).(xvals)
	scatter(a₁, y, leg = false, smooth = false)
	Plots.plot!(xvals, yvals, xlims = (0, 20), ylims = (-2, 15), leg = false)
end

# ╔═╡ 3c7d9f7a-dbaf-4fdf-a1aa-d1c16812379f
md"""
Oben wurde manuell versucht, $w_0$ und $w_1$ so zu bestimmen, dass der Wert der Kostenfunktion $S$ minimal wird. Dabei sind die Argumente `X` und `y` fest vorgegeben (durch die Daten in $\vec{a_1}$ und $\vec{y}$).

D.h. man versucht, eine Funktion mit zwei Variablen ($w_0$,  $w_1$) zu minimieren. Diese Funktion wird im Folgenden explizit als `myS` definiert:
"""

# ╔═╡ 4ecfffe4-ab22-471b-8644-549f980074dc
myS((g1, g2)) = S(g1, g2, a₁, y)

# ╔═╡ 0a0604e3-a4aa-4bbb-842b-eaeca7e04880
md"""
Der Aufruf von `myS` mit den oben eingestellten Werten für ($w_0$,  $w_1$) liefert dementsprechend das gleiche Ergebnis wie der entsprechende Aufruf von `S`.
"""

# ╔═╡ 7824ca23-7db1-41a9-b835-742ead988683
myS((w₀, w₁))

# ╔═╡ 863bfa55-d6dc-4946-9444-be3b7e18453f
md"""
## Gradient Descent "zu Fuß"
"""

# ╔═╡ 183832ff-8ef0-4366-b991-abc37dadb5e2
md"""
Mit dem Gradient-Descent-Verfahren soll nun systematisch das Minimum der Funktion `myS` ermittelt werden. Dazu werden im ersten Schritt die Werte für beide Parameter auf einen willkürlich gewählten Anfangswert gesetzt:
"""

# ╔═╡ 38469754-6594-4902-a69d-b6464b6ffc7b
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
W0 = [2.0, 8.0]
  ╠═╡ =#

# ╔═╡ f8a2147a-1a6a-421e-87ac-c4e0f4bbbdf4
md"""
**Schritt 1**: An diesem Ausgangspunkt `W0` werden der Funktionswert und die Ableitung (Gradient, `grad0`) von `myS` berechnet. Dann wird der Ausgangspunkt um einen kleinen Schritt $\alpha$ entgegen des Gradienten bewegt, wodurch man einen neuen Ausgangspunkt `W1` für den nächsten Iterationsschritt erhält.

Die Schrittweite $\alpha$ wird übrigens *Lernrate* genannt.
"""

# ╔═╡ f0e749a6-a5b8-4f16-8720-33c584c7e60a
#=╠═╡
S0 = myS(W0)
  ╠═╡ =#

# ╔═╡ 0744fbd5-65ac-4fc1-a9a2-804683b8a5db
# ╠═╡ skip_as_script = true
#=╠═╡
grad0 = ForwardDiff.gradient(myS, W0)
  ╠═╡ =#

# ╔═╡ 0f54f782-a5e5-4119-a61a-3384d5357bf8
α = 0.0001

# ╔═╡ a49f5928-ef14-4d3e-96ff-b82e329b68d4
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
W1 = [W0[1] - α * grad0[1], W0[2] - α * grad0[2]]
  ╠═╡ =#

# ╔═╡ 73a699da-40d1-4666-a578-ae37831608bc
md"""
... was auch kompakter wie folgt ausgedrückt werden kann:
"""

# ╔═╡ 67890b76-e5d8-472b-94a4-f2f0f038bb4d
#=╠═╡
W0 - α * grad0
  ╠═╡ =#

# ╔═╡ e0e3a5a7-0e0c-45eb-8ee7-88877f90ff67
md"""
An diesem neuen Punkt ist `myS` schon ein gutes Stück kleiner:
"""

# ╔═╡ 3eda2c51-826f-4305-8ea0-c768d43d347b
#=╠═╡
S1 = myS(W1)
  ╠═╡ =#

# ╔═╡ 98041022-1c95-46b9-b03a-4dd42bbb0922
md"""
Dieses Verfahren wird nun iterativ weitergeführt (**Schritt 2**):
"""

# ╔═╡ fc41001a-5d68-4b4d-8083-700f8ed702c2
#=╠═╡
grad1 = ForwardDiff.gradient(myS, W1)
  ╠═╡ =#

# ╔═╡ 95a936cc-45d0-43ba-a37e-8fa84d06c431
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
W2 = [W1[1] - α * grad1[1], W1[2] - α * grad1[2]]
  ╠═╡ =#

# ╔═╡ 2d731302-7fbd-48e3-a8fe-a6744da950c2
#=╠═╡
S2 = myS(W2)
  ╠═╡ =#

# ╔═╡ 0cef0b7b-4a57-472f-83a5-22839efbfd26
md"""
**Schritt 3:**
"""

# ╔═╡ 9b472ee7-1440-46ad-8bc2-407dbcdc9fea
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
begin
	grad2 = ForwardDiff.gradient(myS, W2)
	W3 = [W2[1] - α * grad2[1], W2[2] - α * grad2[2]]
	S3 = myS(W3)
end
  ╠═╡ =#

# ╔═╡ 4a0de8e5-8708-4d25-b3f4-1747b64be75f
md"""
**Schritt 4:**
"""

# ╔═╡ e6e2becc-33c5-43dd-b04a-5218230be081
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
begin
	grad3 = ForwardDiff.gradient(myS, W3)
	W4 = [W3[1] - α * grad3[1], W3[2] - α * grad3[2]]
	S4 = myS(W4)
end
  ╠═╡ =#

# ╔═╡ 794abd1b-cbcd-4f4c-88dc-da3ef29f37bc
md"""
**Schritt 5:**
"""

# ╔═╡ 26b3a6b6-c2e4-4b76-ba19-0a2207e762d0
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
begin
	grad4 = ForwardDiff.gradient(myS, W4)
	W5 = [W4[1] - α * grad4[1], W4[2] - α * grad4[2]]
	S5 = myS(W5)
end
  ╠═╡ =#

# ╔═╡ d96ac3c4-905c-4f0a-b071-c03c99fd9176
md"""
**Schritt 6:**
"""

# ╔═╡ ea097d6f-a067-485f-ae5c-7551867aeda5
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
begin
	grad5 = ForwardDiff.gradient(myS, W5)
	W6 = [W5[1] - α * grad5[1], W5[2] - α * grad5[2]]
	S6 = myS(W6)
end
  ╠═╡ =#

# ╔═╡ 0af95303-5f6b-45df-9cd3-103937eaa418
md"""
Inzwischen konvergiert der Funktionswert von `myS` nur noch in kleinen Schritten.
"""

# ╔═╡ cbf6d648-eeae-41ab-9fa2-8a09f07b388d
md"""
## 3D-Graph der Kostenfunktion
"""

# ╔═╡ 07dfedd5-5254-403e-a7f6-a5cdaab1a789
md"""
Der folgende 3D-Graph zeigt die Kostenfunktion `myS` im unten durch `w0_range` und `w1_range` angegebenen Wertebereich für die Gewichte $w_0$ und $w_1$:
"""

# ╔═╡ 210d4459-1d4e-44e9-bbed-8e613a4d63ff
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
begin
	w0_range = -1.0:0.1:5.0
	w1_range = -1.0:0.1:5.5
	S_values = [myS([w0, w1]) for w1 in w1_range, w0 in w0_range]
	plotly()
	p = surface(w0_range, w1_range, S_values, 
		xlabel = "w0", ylabel = "w1", cam = (70,40), cbar = false, leg = false)
	Plots.plot(p)
end
  ╠═╡ =#

# ╔═╡ e4344ce2-76c2-4318-ab67-5896a0222b75
md"""
Im nächsten Schaubild sind auch die Punkte `S0` bis `S6`, die schrittweise ermittelt wurden, eingezeichnet.
"""

# ╔═╡ f926ab21-54af-48ad-8819-6fca6bbb4b7c
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
begin
	xpos = [W0[1], W1[1], W2[1], W3[1], W4[1], W5[1], W6[1]]
	ypos = [W0[2], W1[2], W2[2], W3[2], W4[2], W5[2], W6[2]]
	zpos = [S0, S1, S2, S3, S4, S5, S6]
	s = scatter!(p, xpos, ypos, zpos, markersize = 1, color = :yellow)
end
  ╠═╡ =#

# ╔═╡ a07305bb-3c3b-482d-a866-2c8e916fd206
md"""
## Implementierung in Julia
"""

# ╔═╡ 5aec164b-50c5-4054-8ed2-f95d181c41e7
md"""
Gradient Descent als Julia-Funktion:
- `costF` ist die Kostenfunktion, die an der Stelle $W0 = (w0_1, w0_2)$ gestartet wird
- `α` die Schrittweite, um die in Gegenrichtung der Ableitung weitergegangen wird
- Nach `steps` Iterationsschritten wird die Berechnung beendet und
- das optimierte Gewichtepaar als Ergebnis geliefert
"""

# ╔═╡ 0c5be3f6-54d1-4639-b9f2-1dd43688d8cd
function gradDesc(costF, w0₁, w0₂, α, steps)
	pos = [w0₁, w0₂]
	for i = 1:steps
		grad = ForwardDiff.gradient(costF, pos)
		pos -= α * grad
	end
	return(pos)
end

# ╔═╡ 83bd428a-b577-439f-b9cd-77d1f7eb4dc1
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
weights = gradDesc(myS, 10.0, 12.0, 0.0001, 10)
  ╠═╡ =#

# ╔═╡ c9cce9f7-f547-4d3a-9e9c-aeb5819593fe
#=╠═╡
myS(weights)
  ╠═╡ =#

# ╔═╡ 5cc18a56-447e-43a5-b656-dce66b096d03
md"""
## Varianten des Verfahrens
"""

# ╔═╡ 672b0dac-4e9b-47b5-8a91-cb8658260347
md"""
Die Kostenfunktion $S$, die mit dem Gradient-Descent-Verfahren minimiert wird, iteriert über alle $m$ Instanzen an Lerndaten. Das gilt auch für deren Ableitung, die hier verwendet wird (die Ableitung einer Summe von quadratischen Funktionen ist gleich der Ableitung der Summanden). Die hier gezeigte Variante des Verfahrens wird deshalb oft auch **Batch-Gradient-Descent** genannt.

Daraus folgt, dass sowohl $S$ als auch deren Ableitung eine Komplexität von $O(m)$ haben (und das Verfahren insgesamt dann $O(m \times n \times \mathrm{steps})$). Dies wird bei großen Datenmengen zum Problem.

In solchen Fällen verwendet man deshalb eine abgewandelte Variante, die bei jedem Iterationsschritt jeweils nur eine Instanz bei der Berechnung von $S$ betrachtet. Dabei wird beim ersten Iterationsschritt die erste Instanz betrachtet, beim zweiten Schritt die zweite Instanz usw. (bzw. in jedem Schritt eine zufällig ausgewählte Instanz). Somit reduziert sich die Komplexität des Verfahrens auf $O(n \times \mathrm{steps})$. Diese Variante wird **Stochastic-Gradient-Descent** genannt.

Stochastic-Gradient-Descent konvergiert zwar nicht so "zielgerichtet" wie die Batch-Variante und liegt im Ergebnis etwas neben dem Minimum von $S$. Die Unterschiede sind jedoch für die meisten praktischen Anwendungsfälle vernachlässigbar.
"""

# ╔═╡ 15cecb1d-42c2-4a62-99a3-15a1f2ae0d16
md"""
# MLJ - Ein ML-Framework in Julia
"""

# ╔═╡ 15369cf3-0eb4-4529-b26a-78f570402bb1
md"""
## Anwendung eines LR-Modells
"""

# ╔═╡ 67c5ff6e-e24a-452c-a8ba-5542a6d3fe84
md"""
Im ersten Schritt muss das gewünschte ML-Modell (hier `LinearRegressor` aus dem Paket `MLJLinearModels`) geladen werden.
"""

# ╔═╡ 4122b24c-f82a-4372-a831-669f0cd225b9
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
LinearRegressor =  @load LinearRegressor pkg=MLJLinearModels verbosity=2
  ╠═╡ =#

# ╔═╡ 558e9ae1-550c-4560-8789-28f8dda3bfea
md"""
Dann wird eine Instanz davon (mit Default-Parametern) erzeugt:
"""

# ╔═╡ 6a51fc5d-10ee-4838-a7a3-e91e53f80451
#=╠═╡
model = LinearRegressor()
  ╠═╡ =#

# ╔═╡ 2e76b755-8741-49e9-85dd-fa9e77a10f88
md"""
Nun muss das Modell mit den Daten zu einer sog. "Machine" verbunden werden. Die unabhängigen Variablen müssen dabei immer eine Tabellenstruktur bilden die dem `Tables.jl`-Interface entspricht.
"""

# ╔═╡ e330e328-e567-4333-a2f8-c00f980dfc9b
A = (a1 = a₁,)

# ╔═╡ aba76b42-0dd4-4cfc-bc89-08c53e3c54ca
schema(A)

# ╔═╡ 6472cdd7-5da3-48fc-a879-9712295e386a
#=╠═╡
mach = machine(model, A, y)
  ╠═╡ =#

# ╔═╡ b0174652-9e58-44a8-97d3-3432319a4ffa
md"""
Aub dieser Basis können die Parameter ermittelt und deren Güte gleichzeitig über die Kennzahl *root mean square* `rms` gemessen werden. Zur Verbesserung des "Lernprozesses" werden die Daten 
- in der ersten Variante in eine 'Lernmenge' (70% der Daten) und eine Testemenge aufgeteilt.
-  in der zweiten Variante über ein n-Folding (hier mit n = 3) mehrfach für eine optimale Parameterermittlung verwendet.
"""

# ╔═╡ 1032de8e-5fb3-4c8e-8692-94a7f2efb26e
#=╠═╡
evaluate!(mach, resampling = Holdout(fraction_train = 0.7), measure = rms, verbosity = 2)
  ╠═╡ =#

# ╔═╡ 1440a5b6-c3aa-4085-af42-3c869ae59193
#=╠═╡
fitted_params(mach)
  ╠═╡ =#

# ╔═╡ d8e2f2fd-79a7-4476-8517-f0837051f323
cv = CV(nfolds = 3)

# ╔═╡ 86e74714-9230-4bea-ab6c-6a194d87b082
#=╠═╡
evaluate!(mach, resampling = cv, measure = rms, verbosity = 2)
  ╠═╡ =#

# ╔═╡ 4e8c6906-4a8b-414e-a4dd-cefc08de1245
#=╠═╡
fitted_params(mach)
  ╠═╡ =#

# ╔═╡ 09a469f6-4b94-4e9f-807e-56141fc1ad86
md"""
Die zweite Variante liefert einen etwas kleineren RMS und ist somit bezüglich dieser Kennzahl besser.
"""

# ╔═╡ 152b6c74-da5c-43ec-a955-cccfb85ed113
md"""
## Lineare Modelle in MLJ
"""

# ╔═╡ 2216e48b-e921-401b-893a-66073c8c1cf9
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
query(model) = matching(model, A, y) && contains(model.name, "Linear")
  ╠═╡ =#

# ╔═╡ bbc2e380-fa07-4a2c-a97c-5a9b0ac842a3
#=╠═╡
models(query)
  ╠═╡ =#

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
MLJ = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
MLJLinearModels = "6ee0df7b-362f-4a72-a706-9e79364fb692"
MLJMultivariateStatsInterface = "1b6a4a23-ba22-4f51-9698-8599985d3728"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
DataFrames = "~1.3.2"
ForwardDiff = "~0.10.35"
MLJ = "~0.17.1"
MLJLinearModels = "~0.6.0"
MLJMultivariateStatsInterface = "~0.5.2"
Plots = "~1.25.7"
PlutoUI = "~0.7.33"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "6c2d2b9e3a77f7b05429ca79f02234e272917064"

[[deps.ARFFFiles]]
deps = ["CategoricalArrays", "Dates", "Parsers", "Tables"]
git-tree-sha1 = "e8c8e0a2be6eb4f56b1672e46004463033daa409"
uuid = "da404889-ca92-49ff-9e8b-0aa6b4d38dc8"
version = "1.4.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cc37d689f599e8df4f464b2fa3870ff7db7492ef"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra", "Logging"]
git-tree-sha1 = "9b9b347613394885fd1c8c7729bfc60528faa436"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.5.4"

[[deps.Arpack_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "5ba6c757e8feccf03a1554dfaf3e26b3cfc7fd5e"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.1+1"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SnoopPrecompile", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "38911c7737e123b28182d89027f4216cfc8a9da7"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.4.3"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.BSON]]
git-tree-sha1 = "2208958832d6e1b59e49f53697483a84ca8d664e"
uuid = "fbb218c0-5317-5bc6-957e-2ee96dd4b1f0"
version = "0.3.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "5084cc1a28976dd1642c9f337b28a3cb03e0f7d2"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.7"

[[deps.CategoricalDistributions]]
deps = ["CategoricalArrays", "Distributions", "Missings", "OrderedCollections", "Random", "ScientificTypes", "UnicodePlots"]
git-tree-sha1 = "da68989f027dcefa74d44a452c9e36af9730a70d"
uuid = "af321ab8-2d2e-40a6-b165-3d674595d28e"
version = "0.1.10"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "485193efd2176b88e6622a39a246f8c5b600e74e"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.6"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

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

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "89a9db8d28102b094992472d333674bd1a83ce2a"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.1"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "db2a9cb664fcea7836da4b414c3278d71dd602d2"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.6"

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

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

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

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "49eba9ad9f7ead780bfb7ee319f962c811c6d3b2"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.8"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "da9e1a9058f8d3eec3a8c9fe4faacfb89180066b"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.86"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EarlyStopping]]
deps = ["Dates", "Statistics"]
git-tree-sha1 = "98fdf08b707aaf69f524a6cd0a67858cefe0cfb6"
uuid = "792122b4-ca99-40de-a6bc-6742525f08b6"
version = "0.3.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

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

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "7072f1e3e5a8be51d525d64f63d3ec1287ff2790"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.11"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "Setfield", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "03fcb1c42ec905d15b305359603888ec3e65f886"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.19.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "1cd7f0af1aa58abc02ea1d872953a97359cb87fa"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.4"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c98aea696662d09e215ef7cda5296024a9646c75"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.64.4"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "bc9f7725571ddb4ab2c4bc74fa397c1c5ad08943"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.69.1+0"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "0eb6de0b312688f852f347171aba888658e29f20"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "303202358e38d2b01ba46844b92e48a3c238fd9e"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.6"

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
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "d926e9c297ef4607866e8ef5df41cde1a642917f"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.14"

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

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IterationControl]]
deps = ["EarlyStopping", "InteractiveUtils"]
git-tree-sha1 = "d7df9a6fdd82a8cfdfe93a94fcce35515be634da"
uuid = "b3c1a2ee-3fec-4384-bf48-272ea71de57c"
version = "0.5.3"

[[deps.IterativeSolvers]]
deps = ["LinearAlgebra", "Printf", "Random", "RecipesBase", "SparseArrays"]
git-tree-sha1 = "1169632f425f79429f245113b775a0e3d121457c"
uuid = "42fd0dbc-a981-5370-80f2-aaf504508153"
version = "0.9.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JLSO]]
deps = ["BSON", "CodecZlib", "FilePathsBase", "Memento", "Pkg", "Serialization"]
git-tree-sha1 = "7e3821e362ede76f83a39635d177c63595296776"
uuid = "9da8a3cd-07a3-59c0-a743-3fdc52c30d11"
version = "2.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

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
git-tree-sha1 = "2422f47b34d4b127720a18f86fa7b1aa2e141f29"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.18"

[[deps.LatinHypercubeSampling]]
deps = ["Random", "StableRNGs", "StatsBase", "Test"]
git-tree-sha1 = "42938ab65e9ed3c3029a8d2c58382ca75bdab243"
uuid = "a5e1c1ea-c99a-51d3-a14d-a9a37257b02d"
version = "1.8.0"

[[deps.LearnBase]]
git-tree-sha1 = "a0d90569edd490b82fdc4dc078ea54a5a800d30a"
uuid = "7f8f8fb0-2700-5f03-b4bd-41f8cfc144b6"
version = "0.4.1"

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

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "7bbea35cec17305fc70a0e5b4641477dc0789d9d"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.2.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LinearMaps]]
deps = ["ChainRulesCore", "LinearAlgebra", "SparseArrays", "Statistics"]
git-tree-sha1 = "4af48c3585177561e9f0d24eb9619ad3abf77cc7"
uuid = "7a12625a-238d-50fd-b39a-03d52299707e"
version = "3.10.0"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LossFunctions]]
deps = ["InteractiveUtils", "LearnBase", "Markdown", "RecipesBase", "StatsBase"]
git-tree-sha1 = "0f057f6ea90a84e73a8ef6eebb4dc7b5c330020f"
uuid = "30fc2ffe-d236-52d8-8643-a9d8f7c094a7"
version = "0.7.2"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MLJ]]
deps = ["CategoricalArrays", "ComputationalResources", "Distributed", "Distributions", "LinearAlgebra", "MLJBase", "MLJEnsembles", "MLJIteration", "MLJModels", "MLJSerialization", "MLJTuning", "OpenML", "Pkg", "ProgressMeter", "Random", "ScientificTypes", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "ecd156a5494894ea125548ee58226541ee368329"
uuid = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
version = "0.17.3"

[[deps.MLJBase]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Dates", "DelimitedFiles", "Distributed", "Distributions", "InteractiveUtils", "InvertedIndices", "LinearAlgebra", "LossFunctions", "MLJModelInterface", "Missings", "OrderedCollections", "Parameters", "PrettyTables", "ProgressMeter", "Random", "ScientificTypes", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "d95c56713b5ad11732fa012078183f9040d18d4c"
uuid = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
version = "0.19.9"

[[deps.MLJEnsembles]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Distributed", "Distributions", "MLJBase", "MLJModelInterface", "ProgressMeter", "Random", "ScientificTypesBase", "StatsBase"]
git-tree-sha1 = "4279437ccc8ece8f478ded5139334b888dcce631"
uuid = "50ed68f4-41fd-4504-931a-ed422449fee0"
version = "0.2.0"

[[deps.MLJIteration]]
deps = ["IterationControl", "MLJBase", "Random"]
git-tree-sha1 = "9ea78184700a54ce45abea4c99478aa5261ed74f"
uuid = "614be32b-d00c-4edb-bd02-1eb411ab5e55"
version = "0.4.5"

[[deps.MLJLinearModels]]
deps = ["DocStringExtensions", "IterativeSolvers", "LinearAlgebra", "LinearMaps", "MLJModelInterface", "Optim", "Parameters"]
git-tree-sha1 = "0d2ae5a61f8cc762fae8f59cfa8ca4a13521a3c9"
uuid = "6ee0df7b-362f-4a72-a706-9e79364fb692"
version = "0.6.4"

[[deps.MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "c8b7e632d6754a5e36c0d94a4b466a5ba3a30128"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.8.0"

[[deps.MLJModels]]
deps = ["CategoricalArrays", "CategoricalDistributions", "Dates", "Distances", "Distributions", "InteractiveUtils", "LinearAlgebra", "MLJModelInterface", "Markdown", "OrderedCollections", "Parameters", "Pkg", "PrettyPrinting", "REPL", "Random", "ScientificTypes", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "2771980c253c96ca84a0ded1fb2ae34becca995b"
uuid = "d491faf4-2d78-11e9-2867-c94bc002c0b7"
version = "0.15.10"

[[deps.MLJMultivariateStatsInterface]]
deps = ["CategoricalDistributions", "Distances", "LinearAlgebra", "MLJModelInterface", "MultivariateStats", "StatsBase"]
git-tree-sha1 = "1a63598ce4d10800be601c6a759cce4bc9984383"
uuid = "1b6a4a23-ba22-4f51-9698-8599985d3728"
version = "0.5.2"

[[deps.MLJSerialization]]
deps = ["IterationControl", "JLSO", "MLJBase", "MLJModelInterface"]
git-tree-sha1 = "cc5877ad02ef02e273d2622f0d259d628fa61cd0"
uuid = "17bed46d-0ab5-4cd4-b792-a5c4b8547c6d"
version = "1.1.3"

[[deps.MLJTuning]]
deps = ["ComputationalResources", "Distributed", "Distributions", "LatinHypercubeSampling", "MLJBase", "ProgressMeter", "Random", "RecipesBase"]
git-tree-sha1 = "a443cc088158b949876d7038a1aa37cfc8c5509b"
uuid = "03970b2e-30c4-11ea-3135-d1576263f10f"
version = "0.6.16"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.MarchingCubes]]
deps = ["SnoopPrecompile", "StaticArrays"]
git-tree-sha1 = "b198463d1a631e8771709bc8e011ba329da9ad38"
uuid = "299715c1-40a9-479a-aaf9-4a633d36f717"
version = "0.1.7"

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

[[deps.Memento]]
deps = ["Dates", "Distributed", "Requires", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "bb2e8f4d9f400f6e90d57b34860f6abdc51398e5"
uuid = "f28f55f0-a522-5efc-85c2-fe41dfb9b2d9"
version = "1.4.1"

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

[[deps.MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "91a48569383df24f0fd2baf789df2aade3d0ad80"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.10.1"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenML]]
deps = ["ARFFFiles", "HTTP", "JSON", "Markdown", "Pkg"]
git-tree-sha1 = "06080992e86a93957bfe2e12d3181443cedf2400"
uuid = "8b6db2d4-7670-4922-a472-f9537c81ab66"
version = "0.2.0"

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

[[deps.Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "1903afc76b7d01719d9c30d3c7d501b61db96721"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.7.4"

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

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "67eae2738d63117a196f497d7db789821bce61d1"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.17"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

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
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "c95373e73290cf50a8a22c3375e4625ded5c5280"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.4"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "d16070abde61120e01b4f30f6f398496582301d6"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.12"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "5bb5129fdd62a2bbbe17c2756932259acf467386"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.50"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyPrinting]]
git-tree-sha1 = "4be53d093e9e37772cc89e1009e8f6ad10c4681b"
uuid = "54e16d92-306c-5ea0-a30b-337be88ac337"
version = "0.4.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "6ec7ac8412e83d57e313393220879ede1740f9ee"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "261dddd3b862bd2c940cf6ca4d1c8fe593e457c8"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.3"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "dc1e451e15d90347a7decc4221842a022b011714"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.2"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.ScientificTypes]]
deps = ["CategoricalArrays", "ColorTypes", "Dates", "Distributions", "PrettyTables", "Reexport", "ScientificTypesBase", "StatisticalTraits", "Tables"]
git-tree-sha1 = "75ccd10ca65b939dab03b812994e571bf1e3e1da"
uuid = "321657f4-b219-11e9-178b-2701a2544e81"
version = "3.0.2"

[[deps.ScientificTypesBase]]
git-tree-sha1 = "a8e18eb383b5ecf1b5e6fc237eb39255044fd92b"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "3.0.0"

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

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

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

[[deps.StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "3be7d49667040add7ee151fefaf1f8c04c8c8276"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "b8d897fe7fa688e93aef573711cb207c08c9e11e"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.19"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.StatisticalTraits]]
deps = ["ScientificTypesBase"]
git-tree-sha1 = "30b9236691858e13f167ce829490a68e1a597782"
uuid = "64bff920-2084-43da-a3e6-9bb72801c0c9"
version = "3.2.0"

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

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "521a0e828e98bb69042fec1809c1b5a680eb7389"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.15"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

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

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

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

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.UnicodePlots]]
deps = ["ColorSchemes", "ColorTypes", "Contour", "Crayons", "Dates", "LinearAlgebra", "MarchingCubes", "NaNMath", "Printf", "Requires", "SnoopPrecompile", "SparseArrays", "StaticArrays", "StatsBase"]
git-tree-sha1 = "a5bcfc23e352f499a1a46f428d0d3d7fb9e4fc11"
uuid = "b8865327-cd53-5732-bb35-84acbb429228"
version = "3.4.1"

[[deps.Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

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
git-tree-sha1 = "c6edfe154ad7b313c01aceca188c05c835c67360"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.4+0"

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
# ╟─c9fa8be0-8e79-41ee-ab3d-79f06bca89ef
# ╠═3aa2e730-9222-11eb-0fed-97fb58900add
# ╟─670200e0-9222-11eb-0c7f-bd86735f1dca
# ╟─bd64ecac-1e8e-42a6-a8e2-cce2394907f9
# ╟─e22e4a80-9222-11eb-2477-69c243a6f614
# ╟─73292490-922a-11eb-2593-1b967f05f295
# ╟─b08f4770-9224-11eb-0bfc-4516f3638ce0
# ╟─958c57a2-9225-11eb-268f-a7bfdfeeab55
# ╟─c6033920-9249-11eb-2e66-e178b76f56c8
# ╠═818706c0-9224-11eb-0701-03fc802f08b1
# ╟─26955c50-924a-11eb-3b47-b7bb5b76b02d
# ╟─e55f10e0-924a-11eb-1f35-3f1de0285f57
# ╟─1eb06010-924b-11eb-1f9b-1366e692b8f8
# ╠═bd601d00-924a-11eb-0826-7db331e2d358
# ╟─fc88fa2d-016d-4a63-8157-1d6031edd813
# ╟─650948ac-9e2a-462e-ad1d-e343a498c9cf
# ╟─71b5c600-924c-11eb-3dda-414647679cc4
# ╟─45af1a7e-8c92-49d0-aa3c-800b0e4eab60
# ╟─580dc9bc-4aca-4d65-ba61-a0e88dbe7b2d
# ╟─ac8bd5b1-3425-48d5-93b6-81dc92819674
# ╟─aefe9339-c138-4a55-a2fd-b05552e11fcd
# ╟─ab2a9665-5981-45f6-ba1e-97e12136c492
# ╟─17d4279e-9254-11eb-16a5-492585246cae
# ╟─edde71fd-86a8-4d1c-9379-58f594b722aa
# ╠═28061ece-9254-11eb-1fae-817c58c71708
# ╟─bf58b070-8eee-4acf-8aa4-ecc38b2d23b2
# ╠═33b93d40-9257-11eb-15f7-bfa73c4ddf08
# ╟─87c19456-dfd7-4740-a172-13c4789120d6
# ╟─c7dc2bf0-9256-11eb-15e0-6f481470beb2
# ╟─d5efaff2-9256-11eb-389b-e3bb107f9633
# ╠═2a6e6f70-9258-11eb-1f7a-ed5c7f2e88ed
# ╠═d7eed22d-24f9-4533-a5d2-01194d8f2b64
# ╟─3c7d9f7a-dbaf-4fdf-a1aa-d1c16812379f
# ╠═4ecfffe4-ab22-471b-8644-549f980074dc
# ╟─0a0604e3-a4aa-4bbb-842b-eaeca7e04880
# ╠═7824ca23-7db1-41a9-b835-742ead988683
# ╟─863bfa55-d6dc-4946-9444-be3b7e18453f
# ╟─183832ff-8ef0-4366-b991-abc37dadb5e2
# ╠═38469754-6594-4902-a69d-b6464b6ffc7b
# ╟─f8a2147a-1a6a-421e-87ac-c4e0f4bbbdf4
# ╠═f0e749a6-a5b8-4f16-8720-33c584c7e60a
# ╠═0744fbd5-65ac-4fc1-a9a2-804683b8a5db
# ╠═0f54f782-a5e5-4119-a61a-3384d5357bf8
# ╠═a49f5928-ef14-4d3e-96ff-b82e329b68d4
# ╟─73a699da-40d1-4666-a578-ae37831608bc
# ╠═67890b76-e5d8-472b-94a4-f2f0f038bb4d
# ╟─e0e3a5a7-0e0c-45eb-8ee7-88877f90ff67
# ╠═3eda2c51-826f-4305-8ea0-c768d43d347b
# ╟─98041022-1c95-46b9-b03a-4dd42bbb0922
# ╠═fc41001a-5d68-4b4d-8083-700f8ed702c2
# ╠═95a936cc-45d0-43ba-a37e-8fa84d06c431
# ╠═2d731302-7fbd-48e3-a8fe-a6744da950c2
# ╟─0cef0b7b-4a57-472f-83a5-22839efbfd26
# ╠═9b472ee7-1440-46ad-8bc2-407dbcdc9fea
# ╟─4a0de8e5-8708-4d25-b3f4-1747b64be75f
# ╠═e6e2becc-33c5-43dd-b04a-5218230be081
# ╟─794abd1b-cbcd-4f4c-88dc-da3ef29f37bc
# ╠═26b3a6b6-c2e4-4b76-ba19-0a2207e762d0
# ╟─d96ac3c4-905c-4f0a-b071-c03c99fd9176
# ╠═ea097d6f-a067-485f-ae5c-7551867aeda5
# ╟─0af95303-5f6b-45df-9cd3-103937eaa418
# ╟─cbf6d648-eeae-41ab-9fa2-8a09f07b388d
# ╟─07dfedd5-5254-403e-a7f6-a5cdaab1a789
# ╠═210d4459-1d4e-44e9-bbed-8e613a4d63ff
# ╟─e4344ce2-76c2-4318-ab67-5896a0222b75
# ╠═f926ab21-54af-48ad-8819-6fca6bbb4b7c
# ╟─a07305bb-3c3b-482d-a866-2c8e916fd206
# ╟─5aec164b-50c5-4054-8ed2-f95d181c41e7
# ╠═0c5be3f6-54d1-4639-b9f2-1dd43688d8cd
# ╠═83bd428a-b577-439f-b9cd-77d1f7eb4dc1
# ╠═c9cce9f7-f547-4d3a-9e9c-aeb5819593fe
# ╟─5cc18a56-447e-43a5-b656-dce66b096d03
# ╟─672b0dac-4e9b-47b5-8a91-cb8658260347
# ╟─15cecb1d-42c2-4a62-99a3-15a1f2ae0d16
# ╟─15369cf3-0eb4-4529-b26a-78f570402bb1
# ╟─67c5ff6e-e24a-452c-a8ba-5542a6d3fe84
# ╠═4122b24c-f82a-4372-a831-669f0cd225b9
# ╟─558e9ae1-550c-4560-8789-28f8dda3bfea
# ╠═6a51fc5d-10ee-4838-a7a3-e91e53f80451
# ╟─2e76b755-8741-49e9-85dd-fa9e77a10f88
# ╠═e330e328-e567-4333-a2f8-c00f980dfc9b
# ╠═aba76b42-0dd4-4cfc-bc89-08c53e3c54ca
# ╠═6472cdd7-5da3-48fc-a879-9712295e386a
# ╟─b0174652-9e58-44a8-97d3-3432319a4ffa
# ╠═1032de8e-5fb3-4c8e-8692-94a7f2efb26e
# ╠═1440a5b6-c3aa-4085-af42-3c869ae59193
# ╠═d8e2f2fd-79a7-4476-8517-f0837051f323
# ╠═86e74714-9230-4bea-ab6c-6a194d87b082
# ╠═4e8c6906-4a8b-414e-a4dd-cefc08de1245
# ╟─09a469f6-4b94-4e9f-807e-56141fc1ad86
# ╟─152b6c74-da5c-43ec-a955-cccfb85ed113
# ╠═2216e48b-e921-401b-893a-66073c8c1cf9
# ╠═bbc2e380-fa07-4a2c-a97c-5a9b0ac842a3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
