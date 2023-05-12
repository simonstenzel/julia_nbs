### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 6bdea2e8-4a5b-11ec-0cbb-c164c1fb8512
begin
	using Statistics
	using Distributions
	using PlutoUI
end

# ╔═╡ 2d038c6e-d6b3-415d-9dd9-a7593f8f1861
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
">Machine Learning</p>
<p style="text-align: left; font-size: 2.8rem;">
Konfidenzintervalle
</p>

</br></br>

<p style="
font-family: 'Alegreya Sans'; 
font-size: 0.7rem; 
font-weight: 300;
color: #CDCDCD;">

&copy  Dr. Roland Schätzle
</p>
"""

# ╔═╡ aab0f776-f48d-46a9-9ba3-c8716fb18ed0
PlutoUI.TableOfContents(title = "Konfidenzintervalle")

# ╔═╡ 8fea01e3-fea0-44d8-b144-226976b6be1e
md"""
# Konfidenzintervalle berechnen
"""

# ╔═╡ 5d9cea85-6596-467e-8548-5adc4cd5b1a1
md"""
Wenn der beobachtete Mittelwert $p_o$ ist, dann liegt der tatsächliche Mittelwert $p$ mit einer Wahrscheinlichkeit von $c$ im Intervall $[-z \cdot SE, z \cdot SE]$ um $f$ herum.

Der Standarderror $SE$ ist in diesem Fall: $SE = \sqrt{\frac{p (1-p)}{n}}$

D.h. die Breite des Intervalls $2z$ ergibt sich aus: 

$2z = \frac{p_o - p}{SE}$

Oder anders ausgedrückt:

$P(-z < \frac{p_o - p}{SE} < z) = c$

bzw.

$P(-z < \frac{p_o - p}{\sqrt{\frac{p (1-p)}{n}}} < z) = c$
"""

# ╔═╡ a25b3d61-ecf9-4b58-a871-235729ab7f1f
md"""
Wenn man diese Gleichung nach $p$ auflöst, ergibt sich

$p_{1, 2} = \frac{p_o + \frac{z^2}{2n} + z \sqrt{\frac{p_o}{n} + \frac{{p_o}^2}{n} + \frac{z^2}{4n^2}}}{\frac{1 + z^2}{n}}$


"""

# ╔═╡ 554882e6-58f9-4d9e-8f65-31d7ae77b08e
md"""
## Implementierung in Julia
"""

# ╔═╡ 37b52d89-c163-4abf-b699-22448d7e9f7f
md"""
Die Implementierung in Julia sieht wie folgt aus:
"""

# ╔═╡ d2caec4a-31c5-41c9-b8e8-62fda57a2b4a
t1(pₒ, z, n) = pₒ + (z^2/2n)		# erster Teil des Zählers

# ╔═╡ b87743f3-8f18-4735-a89c-aea5375a533b
 t2(pₒ, z, n) = z * sqrt(pₒ/n - pₒ^2/n + z^2/4n^2)		# zweiter Teil des Zählers

# ╔═╡ bc72aeb9-7d3f-465c-a0eb-86d0dc03ff6f
d(z, n) = (1 + z^2/n)		# Nenner

# ╔═╡ 93cad245-446c-4595-8893-c0133d6da564
p(pₒ, z, n) = (
	(t1(pₒ, z, n) - t2(pₒ, z, n)) / d(z, n), 
	(t1(pₒ, z, n) + t2(pₒ, z, n)) / d(z, n)
)

# ╔═╡ e85b3b87-01af-4509-aa1b-5e493ca31488
md"""
## Ermittlung von $z$ aus $c$
"""

# ╔═╡ 53edcbb1-46f5-473e-8fd7-cb573f6520e0
md"""
Die oben definierte Funktion `p(pₒ, z, n)`, die die Grenzen des gesuchten Konfidenzintervalls berechnet, benötigt als Parameter neben der Größe der Stichprobe $n$ und dem in der Stichprobe beobachteten Mittelwert $pₒ$ auch den Wert $z$, der sich aus der vorgegebenen Wahrscheinlichkeit $c$ auf Basis der Normalverteilung wie folgt ergibt:
"""

# ╔═╡ fac04817-8c44-4375-af07-52616bfe2b6b
dist = Normal()

# ╔═╡ e6886ca4-e184-4e18-a824-c56831600e4f
md"""
Die *cumulative densitiy function* `cdf(dist, z)` gibt für eine Verteilung `dist` (hier die Normalverteilung `Normal()`) die Fläche unter der Kurve im Intervall vom Mittelwert bis zum Wert $z \cdot SE$ an.

D.h. `cdf` betrachtet nur den "rechten" Teil der Kurve ab dem Mittelwert (also das Intervall $[\overline{x}, z$]). So liefert sie für $z = 1,65$ einen Wert von ca. $0,95$, da ca. 95% der Kurve im Bereich $[\overline{x}, 1,65]$ und die übrigen 5% der  rechts von $z = 1,65$ liegen.

Möchte man wissen, welcher Anteil der Kurve im Intervall $[-z, z]$ liegt, ist `1 - 2(1 - cdf(dist, z))` zu berechnen (dies entspricht: `-1 + 2cdf(dist, z)` oder auch `1 - 2ccdf(dist, z)`, wobei `ccdf` die zu `cdf` komplementäre Funktion ist).
"""

# ╔═╡ f3a14455-1949-4dba-ab21-e6c73ac9c6e1
1 - 2(1 - cdf(dist, 1.65))

# ╔═╡ 883eae22-e499-49c1-9a31-6cf1be03635c
-1 + 2cdf(dist, 1.65)

# ╔═╡ f4929316-f34b-4fa8-80a8-86ed74a0c303
1 - 2ccdf(dist, 1.65)

# ╔═╡ 10fe6239-c909-4a3d-89aa-2784459bc401
md"""
Eigentlich möchte man aber den umgekehrten Weg gehen, nämlich aus der Wahrscheinlichkeit $c$ den zugehörigen Wert $z$ berechnen.

Im Distribution-Package gibt es nur eine Umkehrfunktion zu `logcdf`, nicht zu `cdf`, so dass man diesen Umweg gehen muss.

Der folgende Ausdruck berechnet z.B. $z$ für den Fall, dass die Kurve über dem Intervall $[\overline{x}, z]$ 95% der Fläche abdecken soll.
"""

# ╔═╡ f4950341-8479-45c2-bd75-c04506ce018d
invlogcdf(dist, log(0.95))

# ╔═╡ 265c6a04-50d0-42a6-82a3-790d9321e9f2
md"""
Möchte man $z$ für die Kurve über dem Intervall $[-z, z]$ für ein bestimmtes $c$ ermitteln, so ist folgender Ausdruck notwendig:
"""

# ╔═╡ 3deb6cba-a294-4e89-8d6d-ede81772f35d
z(c) = invlogcdf(dist, log((1 + c) / 2))

# ╔═╡ 39f2f02e-071a-4708-8350-ad9dd6073dcd
z(0.9)

# ╔═╡ 24c92459-ffca-471d-ba70-d1388d49d59c
md"""
## Alles zusammen
"""

# ╔═╡ 02f6a621-3ef8-4721-949b-e33d703d8863
md"""
Nun angewendet auf einige konkrete Werte:
"""

# ╔═╡ 10a8308d-86d2-4871-87ff-e0cddc1d283b
md"""
Wenn man für einen beobachteten Mittelwert von 0,75 das Intervall wissen möchte, in dem der tatsächliche Mittelwert mit einer Wahrscheinlichkeit von 90% liegt, dann erhält man dies wie folgt (für Stichproben der Größe 100 bzw. 1000):
"""

# ╔═╡ 103e02ff-ce75-4b6f-8d41-0372b68ab42d
z(0.9)

# ╔═╡ 04cbda2f-4efe-4917-acf3-f2a69140bafe
p(0.75, z(0.9), 100)

# ╔═╡ 275e824c-36b5-4bd0-95d8-7ab0ca7132d2
p(0.75, z(0.9), 1000)

# ╔═╡ 63a224bf-ca0e-4677-b0fe-dee913faf726
md"""
Für die oft verwendete Wahrscheinlichkeit von 95% (die einer Intervallbreite von ungefähr $4z$ entspricht) und einem beobachteten Mittelwert von 0,6 ergibt sich:
"""

# ╔═╡ 721a732c-9a14-4271-a4d8-b67d6ea1ae19
z(0.95)

# ╔═╡ 63722ff9-73fb-4e93-b38f-5aa9a5ccef45
p(0.6, z(0.95), 100)

# ╔═╡ 47e9166c-02c2-4442-addd-bb8344a00c83
p(0.6, z(0.95), 1000)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
Distributions = "~0.25.53"
PlutoUI = "~0.7.38"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9950387274246d08af38f6eef8cb5480862a435f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.14.0"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "96b0bc6c52df76506efc8a441c6cf1adcb1babc4"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.42.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "5a4168170ede913a2cd679e53c2123cb4b889795"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.53"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "SpecialFunctions", "Test"]
git-tree-sha1 = "65e4589030ef3c44d3b90bdc5aac462b4bb05567"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.8"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "91b5dcf362c5add98049e6c29ee756910b03051d"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.3"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "58f25e56b706f95125dcb796f39e1fb01d913a71"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.10"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[NaNMath]]
git-tree-sha1 = "737a5957f387b17e74d4ad2f440eb330b39a62c5"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.0"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "e8185b83b9fc56eb6456200e873ce598ebc7f262"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.7"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "621f4f3b4977325b9128d5fae7a8b4829a0c2222"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.4"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "d3538e7f8a790dc8903519090857ef8e1283eecd"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.5"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "5ba658aeecaaf96923dce0da9e703bd1fe7666f9"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.4"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c3d8ba7f3fa0625b062b82853a7d5229cb728b6b"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.1"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8977b17906b0a1cc74ab2e3a05faa16cf08a8291"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.16"

[[StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "25405d7016a47cf2bd6cd91e66f4de437fd54a07"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.16"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─2d038c6e-d6b3-415d-9dd9-a7593f8f1861
# ╟─aab0f776-f48d-46a9-9ba3-c8716fb18ed0
# ╠═6bdea2e8-4a5b-11ec-0cbb-c164c1fb8512
# ╟─8fea01e3-fea0-44d8-b144-226976b6be1e
# ╟─5d9cea85-6596-467e-8548-5adc4cd5b1a1
# ╟─a25b3d61-ecf9-4b58-a871-235729ab7f1f
# ╟─554882e6-58f9-4d9e-8f65-31d7ae77b08e
# ╟─37b52d89-c163-4abf-b699-22448d7e9f7f
# ╠═d2caec4a-31c5-41c9-b8e8-62fda57a2b4a
# ╠═b87743f3-8f18-4735-a89c-aea5375a533b
# ╠═bc72aeb9-7d3f-465c-a0eb-86d0dc03ff6f
# ╠═93cad245-446c-4595-8893-c0133d6da564
# ╟─e85b3b87-01af-4509-aa1b-5e493ca31488
# ╟─53edcbb1-46f5-473e-8fd7-cb573f6520e0
# ╠═fac04817-8c44-4375-af07-52616bfe2b6b
# ╟─e6886ca4-e184-4e18-a824-c56831600e4f
# ╠═f3a14455-1949-4dba-ab21-e6c73ac9c6e1
# ╠═883eae22-e499-49c1-9a31-6cf1be03635c
# ╠═f4929316-f34b-4fa8-80a8-86ed74a0c303
# ╟─10fe6239-c909-4a3d-89aa-2784459bc401
# ╠═f4950341-8479-45c2-bd75-c04506ce018d
# ╟─265c6a04-50d0-42a6-82a3-790d9321e9f2
# ╠═3deb6cba-a294-4e89-8d6d-ede81772f35d
# ╠═39f2f02e-071a-4708-8350-ad9dd6073dcd
# ╟─24c92459-ffca-471d-ba70-d1388d49d59c
# ╟─02f6a621-3ef8-4721-949b-e33d703d8863
# ╟─10a8308d-86d2-4871-87ff-e0cddc1d283b
# ╠═103e02ff-ce75-4b6f-8d41-0372b68ab42d
# ╠═04cbda2f-4efe-4917-acf3-f2a69140bafe
# ╠═275e824c-36b5-4bd0-95d8-7ab0ca7132d2
# ╟─63a224bf-ca0e-4677-b0fe-dee913faf726
# ╠═721a732c-9a14-4271-a4d8-b67d6ea1ae19
# ╠═63722ff9-73fb-4e93-b38f-5aa9a5ccef45
# ╠═47e9166c-02c2-4442-addd-bb8344a00c83
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
