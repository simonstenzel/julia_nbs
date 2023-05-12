### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ f5067e13-b4da-4656-85ba-30fe67e557b2
begin
	using PlutoUI
end

# ╔═╡ df4692bb-73e3-483b-a1d3-e18cea32f15b
html"""
<div style="
position: absolute;
width: calc(100% - 30px);
border: 50vw solid skyblue;
border-top: 500px solid skyblue;
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
background: skyblue;
color: #3366CC;
padding-top: 68px;
padding-left: 5px;
">
<span style="
font-family: Vollkorn, serif;
font-weight: 700;
font-feature-settings: 'lnum', 'pnum';
"> <p style="
font-family: Alegreya sans;
font-size: 1.4rem;
font-weight: 300;
opacity: 1.0;
color: #DCDCDC;
">Julia</p>
<p style="text-align: left; font-size: 2.8rem;">
Arrays
</p>
"""

# ╔═╡ 13fecb22-2fbe-48e4-a031-cec5ed94cf81
PlutoUI.TableOfContents(title = "Arrays")

# ╔═╡ 5de3d619-3d39-4224-b623-2930ce09652f
md"""
# Basics
"""

# ╔═╡ 508375e6-f7ae-4dad-ae57-75c7d5c778c8
md"""
Arrays sind in Julia eine mächtige Basis-Datenstruktur.
"""

# ╔═╡ f40f1150-51ed-4092-9537-d45645ea5869
a = [3, 4, 5]

# ╔═╡ d0e15448-4612-4c2c-9eb2-b94c71b137fb
md"""
*Wichtig*: Die Indexierung von Arrays beginnt immer mit 1!
"""

# ╔═╡ a55278aa-d55b-40ea-811b-ed2c5c8a5893
a[1]

# ╔═╡ 9d502367-f6ac-4f3c-944b-6a67c9d15681
a[1:2]

# ╔═╡ ad70eb92-e303-4af0-ae95-288454feab5a
a[2:end]

# ╔═╡ fa20ae8d-44a6-44e1-9d87-8af53348d1be
md"""
`end` bezeichnet immer den höchsten Indexwert.
"""

# ╔═╡ 7fb0d27b-e259-4520-a57b-6f8498b2f480
a[1:end]

# ╔═╡ 510065d1-a865-4239-b6c8-2cad764383d8
md"""
# Initialisierung von Arrays
"""

# ╔═╡ 430d597a-5771-45f1-8e53-1bb02c4fc1e1
b0 = zeros(5)    # Initialisierung mit 0.0

# ╔═╡ e5b589cc-50e0-434c-b870-a67d2f72446a
b1 = ones(10)    # Initialisierung mit 1.0

# ╔═╡ 725dddaa-4407-4a56-a053-6ff7a284e558
c = rand(20)    # Initialisierung mit Zufallszahlen

# ╔═╡ 838b6c5a-2d9d-480a-96bc-284a7a73d17e
fill!(b1, 3.0)

# ╔═╡ 3e469a39-f85b-45c1-aaec-4773a0cdb7a9
md"""
Per Konvention endet der Funktionsname mit !, wenn die Funktion die als ersten Parameter übergebene Datenstruktur "in place" ändert.
"""

# ╔═╡ 394bc97c-234a-4478-97c9-b0699d460313
b1

# ╔═╡ 8d1ffc66-25f3-47d2-abbc-6e85135e2fbc
d = fill(5.0, 3)

# ╔═╡ 3b11efcd-419d-42d9-a867-41a39d5f9008
md"""
## Wertebereiche (Ranges)
"""

# ╔═╡ 9f9f92ae-22a8-4553-9092-2c1591051ad9
md"""
Ein Wertebereich wird spezifiziert durch die untere und die obere Grenze, getrennt durch einen Doppelpunkt. 
"""

# ╔═╡ c11e5fee-2bd1-4bad-bdb1-edd8f14eeba5
w1 = 1:5

# ╔═╡ 4c72da2f-1c28-4ef8-b52a-c0a0e5092d3f
for i in w1
    println(i)
end

# ╔═╡ 8edf5f6f-d9a6-4bfe-89fb-1e20baf6bb80
md"""
Ranges sind speichereffizient abgelegt. Der Bereich `w3` benötigt genausoviel Speicherplatz wie die Bereiche `w1` oder `w2`. Die darin enthaltenen Werte werden erst generiert, wenn auf diese zugegriffen wird.
"""

# ╔═╡ 55053f1e-d835-4034-b94a-d06ad5dbf047
w3 = 1:1000000

# ╔═╡ 8a74adf8-602c-404d-b0f8-8a2b26f8b383
w4 = 2.5:5.5

# ╔═╡ fe997d5e-23aa-47c7-9216-4fad48dcd732
w5 = 2.5:0.1:3.5

# ╔═╡ e7350ae0-3ecf-4bb4-92e9-0ea68da26e7c
for i in w5
    println(i)
end


# ╔═╡ 070f770b-88a2-4608-8ba0-74188ec83e32
md"""
## Initialisierung mit Comprehensions
"""

# ╔═╡ 4308bdd2-e2d6-4386-905c-15baf7fef98c
md"""
Comprehensions sind ähnlich zu Mengendefinitionen in der Mathematik, bei der die Menge mit Hilfe einer Funktion über einem Wertebereich definiert wird.

In Julia lautet die Syntax dafür: `A = [f(x) for x = a:b]`, wobei `a:b` einen Wertebereich (Range) angibt.
"""

# ╔═╡ feb477b5-998c-40f2-833f-61c4e2b61dde
Q = [x^2 for x = 1:10]

# ╔═╡ 1e152cf6-97f0-4488-a754-1dc78d98f3f4
xx = rand(1:10, 10)

# ╔═╡ 9e7ca77b-3018-42dd-8774-d35595929ce1
md"""
# Iteration
"""

# ╔═╡ f618f177-9d54-404a-ac33-64c83be94aa0
md"""
Wenn man nur auf die Elemente des Arrays zugreifen möchte:
"""

# ╔═╡ d353b76f-50c0-49e4-8ddf-82f209fc5cbc
for q in Q
    println(q)
end

# ╔═╡ 0ad514d7-2b93-4d32-a45d-dcd7b332d1bd
md"""
Wenn man den Index (und evtl. die Elemente) benötig:
"""

# ╔═╡ e7c8e60e-ea43-4355-a950-9b7cdca43028
for i in eachindex(Q)
    println("$i --> $(Q[i])")
end

# ╔═╡ bd2f1de5-9883-475f-9209-dff5cf64cfbf
md"""
Über ein vorangestelltes Dollarzeichen kann man in String-Ausdrücken auf Variablenhinhalte zugreifen. Im obigen Beispiel wird so auf die Inhalte von `i` und `Q[i]` zugegriffen.
"""

# ╔═╡ c2eb2037-6556-44b4-9f7e-f8d99d0c3bb8
md"""
# Julia ist dynamisch typisiert, aber ...
"""

# ╔═╡ 5175be3b-0daf-4023-b13f-a17bc9b3f115
a

# ╔═╡ 04e88b73-94d2-462f-bf06-270c77e1230e
md"""
... die Typinformation wird aus den Inhalten abgeleitet. Somit hat eine Datenstruktur einen festen Typ, sobald dieser Schritt erfolgt ist. Dies sollte bei der Initialiserung mit Werten badacht werden.
"""

# ╔═╡ 094cfe95-1bc3-4ae1-bb20-0db503f2ead9
a[3] = 3.5

# ╔═╡ 3a66eb6b-b766-418e-bb41-e62f3a210086
a[3] = 9

# ╔═╡ 83740d9a-a0b5-456d-9942-84694b137cac
md"""
# Mehrdimensionale Arrays/Matrizen
"""

# ╔═╡ 0d5ffc0b-4484-4c57-bd5e-8a1f2f431b6f
md"""
## Basics
"""

# ╔═╡ 962da638-673b-4578-b7d3-96f4cf9dbc0f
A = [[3, 4, 5] [6, 7, 8]]

# ╔═╡ e38dbe1c-4ce7-4b1a-9652-431717992e51
md"""
Der erste Index wählt die Zeile, der zweite die Spalte.
"""

# ╔═╡ 839cf897-d8cd-41ad-9c5a-a7044dbbf73a
A[2,1]

# ╔═╡ 5399883b-eacf-46e7-9c36-2b945fe770e8
A[1:2, 2]

# ╔═╡ b3acbee7-7ccc-4afc-83dc-375caa96db87
md"""
Wenn als Range lediglich `:` angegeben wird, ist die gleichbedeutend mit `1:end`.
"""

# ╔═╡ 28af5458-0f88-4864-82a0-a84f5fe9a2cc
A[1:2, :]

# ╔═╡ c81f8c4a-986d-4e7d-93d4-4fce09b0d381
md"""
## Initialisierung von mehrdimensionalen Arrays
"""

# ╔═╡ 2e7b9f63-f933-4cf5-be85-cc8f6008307d
B0 = zeros(5, 3)    # Initialisierung mit 0.0

# ╔═╡ e63853d7-3c13-4b1d-814a-893875ec6a74
B1 = ones(4, 5)    # Initialisierung mit 1.0

# ╔═╡ 7d9cc9bd-9010-42e2-92a9-11c0080ab5f2
C = rand(3, 5)    # Initialisierung mit Zufallszahlen

# ╔═╡ c5118470-5aec-473a-b1e1-126cdb5f3b5e
fill!(B1, 3.0)

# ╔═╡ b180db65-c8d5-4911-8652-80c9f89d3117
B1

# ╔═╡ 57db2a59-0d34-4ead-83fc-b72f4391c071
D = fill(5.0, 3, 4)

# ╔═╡ f932ae86-2949-4c6b-ac32-500a6fac4eb4
md"""
### Initialisierung mit Comprehensions
"""

# ╔═╡ 479f5c7f-039f-4d9f-8b02-3b4a149b7b2a
md"""
Dies erfolgt analog zum eindimensionalen Fall. Die Wertebereiche hinter `for` werden dabei durch Komma getrennt.
"""

# ╔═╡ 96bfa817-9fac-4f6d-a546-792a97fd0b35
E = [i + j for i = 1:3, j = 1:5]

# ╔═╡ 6bc3fb76-571f-4458-bfd3-e834a809eb81
md"""
# Nochmal eindimensionale Arrays
"""

# ╔═╡ f45f3830-68b5-452e-9aa1-1abbfaf67607
md"""
Ein ein eindimensionales Array ist ein Spaltenvektor.
"""

# ╔═╡ 65961228-f580-49dd-b675-1daa8d80113a
a

# ╔═╡ d9c90876-6e21-4654-be4a-8229abe2466d
z = [3 6 9]

# ╔═╡ 311c97f1-2ebb-47fd-91dc-760a8bcb8cef
md"""
Im Gegensatz dazu ist `z` ein einzeiliges Array mit drei Spalten. 

Mit dem Leerzeichen findet eine horizontale Verkettung statt, während das Semikolon vertikal verkettet.
"""

# ╔═╡ 4258536c-3ce6-4512-ba16-29f7cbe328c0
md"""
Bei (eindimensionalen) Arrays können Komma und Semikolon gleichwertig verwendet werden.
"""

# ╔═╡ 476e5a57-b11a-45a3-b6cd-d4ea59b5cabc
v = [4, 5, 6]

# ╔═╡ 51569598-1717-4c38-935a-e6116e6041f1
w = [4; 5; 6]

# ╔═╡ 2cdda379-8ea7-4e61-bbae-d825ae2c7a6c
md"""
## Verkettung zweidimensional
"""

# ╔═╡ b46cda06-8cfc-4b8c-841e-f4907d995656
X = [[1 2] [3 4]; [5 6] [7 8]] 

# ╔═╡ 657ff489-6ec2-491c-9811-bcc9ab125aa8
Y = [[1, 2] [3, 4] [5, 6] [7, 8]]

# ╔═╡ 89ecceed-43ce-4d25-acb0-72c61cf10337
Z = [[1, 2] [3, 4]; [5, 6] [7, 8]]

# ╔═╡ ae919b85-cdb8-4653-860e-596266811772
md"""
 Bei eindim. Arrays können die Komponenten stattdessen auch mit Komma getrennt wernde.
"""

# ╔═╡ bec0f377-e428-49f4-82a9-645e28e71543
md"""
## Iteration
"""

# ╔═╡ 030a0e11-6bc8-4ba1-ad04-9babe273b04e
md"""
Über mehrdimensionale Arrays kann sequentiell iteriert werden. Dabei wird eine Column-First-Reihenfolge angewendet.
"""

# ╔═╡ 3573e853-06a5-485a-8f54-19da2d566320
X

# ╔═╡ 53112544-ab70-484c-b2ae-1756b7d65016
for x in X
	println(x)
end

# ╔═╡ 311ce9d6-a93a-4155-9bd4-242b4f84db91
for i in eachindex(X)
	println("$i --> $(X[i])")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.50"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "d8b0bbb312600ec81f2769bd72048a77429debd9"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

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

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6f4fbcd1ad45905a5dee3f4256fabb49aa2110c6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.7"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "5bb5129fdd62a2bbbe17c2756932259acf467386"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.50"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─df4692bb-73e3-483b-a1d3-e18cea32f15b
# ╟─f5067e13-b4da-4656-85ba-30fe67e557b2
# ╟─13fecb22-2fbe-48e4-a031-cec5ed94cf81
# ╟─5de3d619-3d39-4224-b623-2930ce09652f
# ╟─508375e6-f7ae-4dad-ae57-75c7d5c778c8
# ╠═f40f1150-51ed-4092-9537-d45645ea5869
# ╟─d0e15448-4612-4c2c-9eb2-b94c71b137fb
# ╠═a55278aa-d55b-40ea-811b-ed2c5c8a5893
# ╠═9d502367-f6ac-4f3c-944b-6a67c9d15681
# ╠═ad70eb92-e303-4af0-ae95-288454feab5a
# ╟─fa20ae8d-44a6-44e1-9d87-8af53348d1be
# ╠═7fb0d27b-e259-4520-a57b-6f8498b2f480
# ╟─510065d1-a865-4239-b6c8-2cad764383d8
# ╠═430d597a-5771-45f1-8e53-1bb02c4fc1e1
# ╠═e5b589cc-50e0-434c-b870-a67d2f72446a
# ╠═725dddaa-4407-4a56-a053-6ff7a284e558
# ╠═838b6c5a-2d9d-480a-96bc-284a7a73d17e
# ╟─3e469a39-f85b-45c1-aaec-4773a0cdb7a9
# ╠═394bc97c-234a-4478-97c9-b0699d460313
# ╠═8d1ffc66-25f3-47d2-abbc-6e85135e2fbc
# ╟─3b11efcd-419d-42d9-a867-41a39d5f9008
# ╟─9f9f92ae-22a8-4553-9092-2c1591051ad9
# ╠═c11e5fee-2bd1-4bad-bdb1-edd8f14eeba5
# ╠═4c72da2f-1c28-4ef8-b52a-c0a0e5092d3f
# ╟─8edf5f6f-d9a6-4bfe-89fb-1e20baf6bb80
# ╠═55053f1e-d835-4034-b94a-d06ad5dbf047
# ╠═8a74adf8-602c-404d-b0f8-8a2b26f8b383
# ╠═fe997d5e-23aa-47c7-9216-4fad48dcd732
# ╠═e7350ae0-3ecf-4bb4-92e9-0ea68da26e7c
# ╟─070f770b-88a2-4608-8ba0-74188ec83e32
# ╟─4308bdd2-e2d6-4386-905c-15baf7fef98c
# ╠═feb477b5-998c-40f2-833f-61c4e2b61dde
# ╠═1e152cf6-97f0-4488-a754-1dc78d98f3f4
# ╟─9e7ca77b-3018-42dd-8774-d35595929ce1
# ╟─f618f177-9d54-404a-ac33-64c83be94aa0
# ╠═d353b76f-50c0-49e4-8ddf-82f209fc5cbc
# ╟─0ad514d7-2b93-4d32-a45d-dcd7b332d1bd
# ╠═e7c8e60e-ea43-4355-a950-9b7cdca43028
# ╟─bd2f1de5-9883-475f-9209-dff5cf64cfbf
# ╟─c2eb2037-6556-44b4-9f7e-f8d99d0c3bb8
# ╠═5175be3b-0daf-4023-b13f-a17bc9b3f115
# ╟─04e88b73-94d2-462f-bf06-270c77e1230e
# ╠═094cfe95-1bc3-4ae1-bb20-0db503f2ead9
# ╠═3a66eb6b-b766-418e-bb41-e62f3a210086
# ╟─83740d9a-a0b5-456d-9942-84694b137cac
# ╟─0d5ffc0b-4484-4c57-bd5e-8a1f2f431b6f
# ╠═962da638-673b-4578-b7d3-96f4cf9dbc0f
# ╟─e38dbe1c-4ce7-4b1a-9652-431717992e51
# ╠═839cf897-d8cd-41ad-9c5a-a7044dbbf73a
# ╠═5399883b-eacf-46e7-9c36-2b945fe770e8
# ╟─b3acbee7-7ccc-4afc-83dc-375caa96db87
# ╠═28af5458-0f88-4864-82a0-a84f5fe9a2cc
# ╟─c81f8c4a-986d-4e7d-93d4-4fce09b0d381
# ╠═2e7b9f63-f933-4cf5-be85-cc8f6008307d
# ╠═e63853d7-3c13-4b1d-814a-893875ec6a74
# ╠═7d9cc9bd-9010-42e2-92a9-11c0080ab5f2
# ╠═c5118470-5aec-473a-b1e1-126cdb5f3b5e
# ╠═b180db65-c8d5-4911-8652-80c9f89d3117
# ╠═57db2a59-0d34-4ead-83fc-b72f4391c071
# ╟─f932ae86-2949-4c6b-ac32-500a6fac4eb4
# ╟─479f5c7f-039f-4d9f-8b02-3b4a149b7b2a
# ╠═96bfa817-9fac-4f6d-a546-792a97fd0b35
# ╟─6bc3fb76-571f-4458-bfd3-e834a809eb81
# ╟─f45f3830-68b5-452e-9aa1-1abbfaf67607
# ╠═65961228-f580-49dd-b675-1daa8d80113a
# ╠═d9c90876-6e21-4654-be4a-8229abe2466d
# ╟─311c97f1-2ebb-47fd-91dc-760a8bcb8cef
# ╟─4258536c-3ce6-4512-ba16-29f7cbe328c0
# ╠═476e5a57-b11a-45a3-b6cd-d4ea59b5cabc
# ╠═51569598-1717-4c38-935a-e6116e6041f1
# ╟─2cdda379-8ea7-4e61-bbae-d825ae2c7a6c
# ╠═b46cda06-8cfc-4b8c-841e-f4907d995656
# ╠═657ff489-6ec2-491c-9811-bcc9ab125aa8
# ╠═89ecceed-43ce-4d25-acb0-72c61cf10337
# ╟─ae919b85-cdb8-4653-860e-596266811772
# ╟─bec0f377-e428-49f4-82a9-645e28e71543
# ╟─030a0e11-6bc8-4ba1-ad04-9babe273b04e
# ╠═3573e853-06a5-485a-8f54-19da2d566320
# ╠═53112544-ab70-484c-b2ae-1756b7d65016
# ╠═311ce9d6-a93a-4155-9bd4-242b4f84db91
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
