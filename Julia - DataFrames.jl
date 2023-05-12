### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 156d8654-bebe-4be8-b217-161f53244ed7
begin
	using PlutoUI
	using DataFrames
	using Query
	using DataFramesMeta
	using CSV
	using RDatasets
end

# ╔═╡ f9f5a2d9-1dec-4a62-9c0c-d45c4ea2f448
using Statistics

# ╔═╡ 6ee75a61-9ca7-4b4d-a3c8-57d0d66f7a6e
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
">Julia</p>
<p style="text-align: left; font-size: 2.8rem;">
DataFrames
</p>

<p style="
font-family: 'Alegreya Sans'; 
font-size: 0.7rem; 
font-weight: 300;
color: #CDCDCD;">

&copy  Dr. Roland Schätzle
</p>
"""

# ╔═╡ ad98eefd-2d67-4419-9955-20965b6dbde0
PlutoUI.TableOfContents(title = "DataFrames")

# ╔═╡ 7f70001a-d8f3-4a5f-8be4-a301af035059
md"""
# Basics
"""

# ╔═╡ a1a653cf-d838-4ca6-ac16-b9f5c641c1da
md"""
`DataFrames` ist ein Julia-Package, das es erlaubt, tabellenartige Datenstrukturen, ähnlich einem Spreadsheet oder einer Datenbanktabelle, zu bearbeiten. Im Gegensatz zu einem zweidimensionalen Array kann jede Spalte eines `DataFrames` einen anderen Datentyp haben.
"""

# ╔═╡ 3a45da57-6203-44cf-87a7-71c6225bc086
md"""
`DataFrames`sind von der Grundstruktur her eine Folge von Spaltenvektoren. Dementsprechend können sie auch in dieser Form initialisert werden.
"""

# ╔═╡ a47ab0bc-a2a9-4e50-af77-c91fd265c4a1
df = DataFrame(Name = ["David", "Lisa", "Tim"], Alter = [23, 25, 21], Groesse = [180, 178, 175])

# ╔═╡ 608fa022-c5d5-46b2-bbd1-721a1c00709e
md"""
Jede Spalte hat dabei einen Namen (Spaltenüberschrift). Über diesen Namen ist der Zugriff auf die Spalte über folgende Notationen möglich:
"""

# ╔═╡ bc82b97c-60b3-424e-be89-6d9d42242742
df.Name

# ╔═╡ 86bd6873-628d-4a06-919a-df7bd2c88609
df."Name"

# ╔═╡ cf52a390-ba15-4b78-98b0-f4b448a64685
df[:, :Name]

# ╔═╡ ea5eead6-3ffe-4373-b6a2-a4657f5bfbf6
df[:, "Name"]

# ╔═╡ 55caaf85-a413-4c5a-a442-081b2f625dd7
md"""
Die obigen Notationen mit `:` liefern eine Kopie des Spaltenvektors, während die analoge Notation mit `!` den originalen Spaltenvektor liefert:
"""

# ╔═╡ d0958dbc-f829-42fd-8447-add92603ff47
df[!, :Name]

# ╔═╡ 0aab5dd8-6f7a-462e-b78f-a772363838b8
df[!, :Name][3] = "Timothy"

# ╔═╡ 9736c414-d14f-4da7-91f9-e2957864e9ba
df

# ╔═╡ 14057046-0a9a-459f-b00c-e48e038248fd
md"""
## `DataFrames` haben Überschriften
"""

# ╔═╡ c863b406-d59a-4ea1-a1b8-3e7396477fab
md"""
Die Namen der Überschriften als Strings erhält man über die `names()`-Funktion, während `propertynames()` Symbole liefert.
*Hinweis*: Der Zugriff auf die Spalten über Symbole ist etwas schneller als über Strings und somit die bevorzugte Methode.
"""

# ╔═╡ 6bdd5ea5-eee5-4ffa-96ea-a2c07c3b8879
names(df)

# ╔═╡ 054ae231-59a3-4eae-9fa4-177f17e4358a
propertynames(df)

# ╔═╡ ab918d79-7871-4842-8c00-50bfe15c8bec
md"""
## Initialisierung: Schritt für Schritt
"""

# ╔═╡ 3258eb8e-4ce2-452f-965e-c17c95bb94f4
md"""
Man kann ein `DataFrame` auch schrittweise aufbauen:
"""

# ╔═╡ 8f706489-9be4-4d0c-a402-4ea9f9bed5b3
begin
	df2 = DataFrame()
	df2.Name = ["Anne", "Jonas"]
end

# ╔═╡ 28d57e03-bbbf-4591-b995-56dcae8c3716
df2.Alter = [27, 19]

# ╔═╡ 6191b590-f5fb-4fec-9818-b8d4450b20af
md"""
Neue Zeilen können mit `push!(df, zeile)` hinzugefügt werden, wobei `zeile` ein Array oder ein Tupel sein kann.
"""

# ╔═╡ 14c6f59d-8145-4c1a-80fe-a89afa330e28
push!(df2, ["Kai", 29])

# ╔═╡ 50f53b95-2783-4019-a6ac-594efa2776ad
md"""
Mit `size()` kann die Größe des DataFrame festgestellt werden:
"""

# ╔═╡ 634df5be-5bb0-4774-94e4-1e3a8eee9701
size(df2)

# ╔═╡ b172e1f0-16fa-44d7-8773-ec4eebdcacc9
md"""
`describe` liefert einige statistische Kennzahlen. Die Funktion kann auch sleketiv auf einzelne Spalten angwendet werden.
"""

# ╔═╡ dd01015e-6ec0-439a-94d8-89d7996d67f5
describe(df)

# ╔═╡ 202b4062-e41e-4f9f-b4d8-0cb67852b6a1
md"""
## Zugriff auf Werte mittels Indexierung
"""

# ╔═╡ b79487ca-098b-45dd-a9fe-807ca7e2220e
md"""
Der Zugriff auf die Inhalte über Indexierung erfolgt analog zu Arrays.
"""

# ╔═╡ 8b44565f-4ac4-4178-ac47-feb79385d958
df2[2:3, 1:end]

# ╔═╡ e191014d-0419-427f-b1dd-b54f59bc0aa7
df2[[1,3], :]

# ╔═╡ ab181bb8-6990-4941-9e86-6ce28a7198dd
df[[1,3], [:Name, :Groesse]]

# ╔═╡ 7b694353-0bcc-4b7d-b36a-1c248d7227f7
md"""
*Hinweis*: Bei einspaltigen Ergebnissen kann sowohl ein `DataFrame` als auch der Spaltenvektor zurückgegeben werden:
"""

# ╔═╡ d3c7d404-b1d4-49aa-bc27-a885bf9e0f41
df[:, [:Name]]    # ein DataFrame

# ╔═╡ 2174755e-0e67-46d9-aa6d-5e1e627e7cae
df[:, :Name]    # ein Spaltenvektor

# ╔═╡ 06f0ee84-2709-4451-90d9-b78136a5027a
md"""
# Es ist aber auch deutlich mehr möglich
"""

# ╔═╡ 50ec26f7-b094-457d-bea1-65b77fabaebb
md"""
## Reguläre Ausdrücke
"""

# ╔═╡ 040e3ba4-3317-4423-b20a-fe918a36a488
md"""
Es können reguläre Ausdrücke (Perl-Syntax) verwendet werden. Hier z.B. alle Überschriften, die ein "r" enthalten:
"""

# ╔═╡ 75cdd729-4b79-48c8-85c9-ba595c588d60
df[:, r"r"]

# ╔═╡ 1cc4a162-47f7-46ca-a728-a70f3dedd807
md"""
## Bedingungen
"""

# ╔═╡ 54c883ca-f230-41ae-810b-e24de82a7adc
md"""
Auf die Zelleneinträge können Bedingungen angwendet werden.
"""

# ╔═╡ 557769b4-a685-4887-b381-e82b981ecf35
md"""
Wir möchten z.B. alle Personen, die jünger als 25 sind. Dementsprechend müssen die Zeilen im DataFrame gefiltert werden.
"""

# ╔═╡ 1114085d-4588-43e9-a2ea-e44a12d08d1b
[df.Alter[1] < 25,
df.Alter[2] < 25,
df.Alter[3] < 25]

# ╔═╡ 3aba39cc-c862-4a6a-ba43-9c6318a8086e
md"""
### Bedingungen und Broadcasting
"""

# ╔═╡ f6b3a2d4-a892-4955-bf97-5d73e8e23aec
md"""
Das geht kürzer mit "Broadcasting" mittels des `.`-Operators:
"""

# ╔═╡ 9b5a1bb5-4e4e-4149-8318-6b88bb775e18
df.Alter .< 25

# ╔═╡ 81d71534-b2c3-4a14-bdef-eb4fed6bce92
df[df.Alter .< 25, :]

# ╔═╡ 21a4f261-e1c9-4535-80ca-6afdd3018ed6
md"""
Solche Bedingungen können auch über logische Operatoren miteinander verknüpft werden (dabei korrekte Klammerung beachten!).
"""

# ╔═╡ 2b527b3b-3c98-455b-b205-145de0209f08
df[(df.Alter .< 25) .& (df.Groesse .< 180), :]

# ╔═╡ 5eb955e6-1107-4d9d-915e-9d75915b8a35
filter(x -> (x.Alter < 25) & !ismissing(x.Groesse) & (x.Groesse < 180), df)

# ╔═╡ 018a9ad9-f8ee-4be7-8bb0-4ff69be05760
df.Groesse .- df.Alter

# ╔═╡ ffdd5b9a-cdc8-4084-8e73-791b20c790a0
md"""
## Query-Package
"""

# ╔═╡ 8f34a304-4a80-4a7b-a383-55ac3e06ec46
md"""
Eine vollständige Abfragesprache, die u.a. mit DataFrames arbeitet, bietet das `Query`-Package. Dieses Package gehört zum [Queryverse-Projekt](https://www.queryverse.org/). Es bietet zwei Arten der Abfrage-Syntax: Eine Implementierung von LINQ ([Language Integrated Query](https://de.wikipedia.org/wiki/LINQ) sowie die sog. *Standalone Query Syntax*, die den *Pipe*-Mechanismum von Julia nutzt.
"""

# ╔═╡ e12c0548-8c4c-414a-96c4-bc5a225b1d2d
md"""
Hier ein Beispiel für die LINQ-Syntax:
"""

# ╔═╡ 8209e5f8-576d-434e-b746-9e2b74b9fdbe
result = @from data in df begin
    @where data.Alter < 25
    @select {data.Name, data.Groesse}
    @collect DataFrame
end

# ╔═╡ abbb00e3-a7ca-4958-9c99-6c32cedde849
md"""
Und dieselbe Abfrage mit der Standanlone Query Syntax:
"""

# ╔═╡ 77c1f6c3-77ae-4c21-9306-bbef0878b2c7
df |> @filter(_.Alter < 25) |> Query.@select(:Name, :Groesse) |> DataFrame

# ╔═╡ 79e3b772-80ff-43aa-aec7-a5a19f7b5026
md"""
## DataFramesMeta-Package
"""

# ╔═╡ 3137f49c-bdef-4831-9f4f-9d4155e70bc2
md"""
Eine Alternative zum `Query`-Package ist das `DataFramesMeta`-Package, welches mit Julia-Macros und Pipes arbeitet.
"""

# ╔═╡ 7f28ef90-9cdc-4cc0-8645-ce447a87c26b
@linq df |> 
    where(:Alter .< 25) |>
    select(:Name, :Groesse)

# ╔═╡ 3a8f6c76-d660-41d4-8390-8e0fa4dc037e
md"""
# Änderung von Inhalten
"""

# ╔═╡ e357e7cc-494a-4b93-9838-bd4c040069d5
md"""
Einzelnen Zellen im DataFrame können direkt Werte zugewiesen werden:
"""

# ╔═╡ 8f50363d-33db-4cdb-a133-32d890d73305
df[1, :Alter] = 21

# ╔═╡ d0422cc7-81dd-4b0b-b9d2-b6e08680f76b
df

# ╔═╡ e230f184-7c9a-4975-9e78-1a491b42cb4e
md"""
Mittels `replace(col, old => new)` können Werte in einer gesamten Spalte geändert werden. Die variante `replace!` führt die Änderung "in-place" aus.
"""

# ╔═╡ 5c7ba83b-2090-426e-9073-a3aebf7b7025
replace!(df.Alter, 21 => 24)

# ╔═╡ 118131e9-e574-4df3-ad54-e1a861aadcb5
df

# ╔═╡ be96cec2-27dd-4a3b-bb5c-5a311cf8fe1e
md"""
Die Funktion `unique(col)` liefert die eindeutigen Werte in einem Array (oder auch in einem `DataFrame`).
"""

# ╔═╡ 9c758b85-687d-4960-be8a-9faf45d48652
unique(df.Alter)

# ╔═╡ 1663c898-a2b9-4665-aad1-79b5426aa6ca
md"""
# Arbeiten mit CSV-Dateien
"""

# ╔═╡ 508e6581-186f-4141-8926-495ed22343ea
md"""
DataFrames werden oft mit Inhalten aus CSV-Dateien initialisiert und nach entsprechender Bearbeitung können sie auch wieder in einer CSV-Datei gespeichert werden. Um mit CSV-Dateien zu arbeiten, wird das CSV-Package benötigt.
"""

# ╔═╡ bf6b76b9-a87a-4cfe-b3d9-cfc832e48aaf
CSV.write("UnserCSV-Beispiel.csv", df)

# ╔═╡ 4a4fe317-7e1e-47bb-96e3-9ab2a67a0356
dfAusDatei = CSV.read("UnserCSV-Beispiel.csv", DataFrame)

# ╔═╡ 7de0578f-1047-42a5-b309-a92f306f629b
md"""
# Umgang mit fehlenden Datenwerten
"""

# ╔═╡ 76d8bafc-5cb4-4ac9-830a-0aec504d30ee
md"""
Bei größeren, realen Datensammlungen ist es nicht untypisch, dass man nicht für alle Einträge einen Wert hat. Auch damit muss eine Struktur wie die DataFrames umgehen können. In Julia gibt es dafür den vordefinierten Wert `missing`, den man in beliebigen Datenstrukturen verwenden kann.
"""

# ╔═╡ d156eebf-312c-469c-8c84-a96698c46646
a = [3, 6, missing]

# ╔═╡ 95027329-a72d-480f-a0db-3d8c91dd6ba1
md"""
Diverse Funktionen berücksichtigen diese `missing`-Werte bei Berechnungen:
"""

# ╔═╡ 038a99b6-63f9-4d4f-8504-1195c93dbaea
mean(a)    # Auf Grund des fehlenden Wertes, dann der Mittelwert nicht berechnet werden.

# ╔═╡ aa394e2b-9bba-4415-857f-87fa53eaca89
mean(skipmissing(a))    # ... außer man fordert Julia explizit auf, solche Werte zu ignorieren

# ╔═╡ 91bfe422-0d30-43ab-beb9-3bf83f323405
md"""
Bei DataFrames muss explizit erlaubt werden, dass es fehlende Werte geben darf. Dies erfolgt entweder dadurch, dass bei der Initialisierung schon Werte fehlen oder im Nachgang durch `allowmissing!(df)`. Die entsprechende Erlaubnis kann durch `disallowmissing!(df)` wieder entzogen werden.
"""

# ╔═╡ fb5b08d6-75a2-4837-9757-8b7bb3697b2a
allowmissing!(df)

# ╔═╡ 6ba0effe-b9f6-4768-ab09-45a58e2cb187
df[1, :Groesse] = missing

# ╔═╡ 040f8dc5-c962-4b76-a7e4-59cde85bd2aa
df

# ╔═╡ 7d7db307-4efc-4c5a-935a-5ec6823dbea6
md"""
Mit `dropmissing(df)` (bzw. `dropmissing!(df)`) könnne im gesamten `DataFrame` Zeilen mit fehlenden Werten entfernt werden.
"""

# ╔═╡ 1f1bb4a6-00cb-4c3a-9617-6c1bfda12f8d
dropmissing(df)

# ╔═╡ d5ca3e9f-6cb8-479a-a083-41be3ca34a4c
md"""
# DataFrames mit "echten" Daten
"""

# ╔═╡ 34756233-efe9-4bbe-836e-b4c033932e24
md"""
## RDatasets
"""

# ╔═╡ 147f67f2-c8c1-4b0b-a98f-7d9df56d99c8
md"""
Das Package `RDatasets` umfasst eine große Anzahl von Datensammlungen, die üblicherweise im Bereich Data-Science für (Lehr-)Beispiele und Tests genutzt wird. Einige dieser Datensammlungen werden im Folgenden genutzt, um die Funktionalität von `DataFrames` zu demonstrieren.
"""

# ╔═╡ 2a673fed-c620-4125-b475-bd3ad6683b6e
md"""
Die Datensammlungen sind dabei in sog. Packages unterteilt. Jedes Package enthält eine ganze Reihe von Datensammlungen. Hier z.B. die Liste der Datensammlungen im Package "datasets" (Eintrag 14):
"""

# ╔═╡ 4e47b5c1-b260-44dd-9088-a906d655c46d
RDatasets.packages()

# ╔═╡ db35675e-a47b-4078-9245-dc48e6a39596
RDatasets.packages()[14, :]

# ╔═╡ ae1bed5b-5035-4a78-9205-d77578b47b44
md"""
Hier nun die Datensammlungen aus dem Package "datasets":
"""

# ╔═╡ d05a9f64-85c9-413a-bac6-060e0b63b120
RDatasets.datasets("datasets") 

# ╔═╡ 39595b24-1c83-4719-bf24-8cea314fb55a
md"""
## Das Iris-Dataset
"""

# ╔═╡ bab94802-4c72-42ba-a23c-22efa270e3a5
md"""
Eine sehr bekannte und in vielen (Lehr-)Beispielen verwendete Sammlung ist das [Iris-Dataset](https://en.wikipedia.org/wiki/Iris_flower_data_set). Es enthält Daten zu verschiedenen Arten von [Schwertlilien](https://de.wikipedia.org/wiki/Schwertlilien) (Iris). Es wurde erstmalig 1936 vom Britischen Biologen und Statistiker Ronald Fisher in einem Paper verwendet.
"""

# ╔═╡ 9db138e2-d87c-4266-acb4-c4ee6995e162
md"""
Es umfasst die Länge und Breite der Kelchblätter (Sepal) sowie Länge und Breite der Blütenblätter (Petal) für unterschiedliche Iris-Arten.
"""

# ╔═╡ 295e6cd7-2ad1-4633-aae1-c7fa0236b933
iris = dataset("datasets", "iris")

# ╔═╡ ab4c7e10-ad48-4cbf-bd4b-53b0f031a918
md"""
### Aufgaben
"""

# ╔═╡ 64237ec9-cd5e-409c-af55-9f1fb65ae318
md"""
1. Ermitteln Sie grundlegende statistische Kennzahlen zur Iris-Datensammlung.
    - Wie lange sind die Blütenbläter (Petal ...) mindestens?
    - Wie lange sind die Kelchblätter (Sepal ...) höchstens?
2. Wieviele unterschiedliche Arten von Schwertlilien werden beschrieben? Wie heißen sie?
3. Erzeugen Sie ein DataFrame mit allen Pflanzen, die eine Blütenblätter-Breite von höchstens 0,2 haben.
4. Welche Einträge haben eine Blütenblätter-Breite von höchstens 0,3, aber gleichzeitig eine Länge von mindestens 2,0?
"""

# ╔═╡ 3f7eecb0-e898-42ac-908e-33b008116446
md"""
### Lösungen
"""

# ╔═╡ d40c393b-789f-4107-9bdd-68153001b6e7
describe(iris)

# ╔═╡ 5dd644c3-740d-4f9e-a554-0cbf4beb0420
md"""
Die Blütenblätter haben eine Mindestlänge von 1,0 und die Kelchblätter sind höchstens 7,9 lang.
"""

# ╔═╡ 80858633-2a74-4e58-b6bd-b37ef44096d6
unique(iris.Species)

# ╔═╡ 8edee3ed-22d6-4399-af68-3ec01f5d95c0
iris[iris.PetalWidth .<= 0.2, :]

# ╔═╡ ca65370a-130e-4e40-ad9b-275b1796939d
iris[(iris.PetalWidth .<= 0.2) .& (iris.PetalLength .>= 2.0), :]

# ╔═╡ 4fb42c0b-53b7-43f0-8c09-b09a019f8713
md"""
Es gibt also keine derartigen Einträge.
"""

# ╔═╡ 90bdab1f-a2af-4674-b802-a0f10c09cb0c
md"""
## Das Cars93-Dataset
"""

# ╔═╡ 1330795f-97e0-414c-8204-ccfe45c62193
cars = dataset("MASS", "Cars93")

# ╔═╡ 2fbce769-4082-4c93-8d3a-0762dab7ba7a
md"""
### Aufgaben
"""

# ╔═╡ 319d9b13-8cc7-47d4-a599-57393a2a9d62
md"""
1. Verschaffen Sie sich einen Überblick über die Tabelle und die wichtigsten statistischen Kennzahlen.
2. Wieviele unterschiedliche Hersteller umfasst die Liste? Wie heißen sie?
3. Wieviele unterschiedliche Modelle gibt es? Wie heißen sie?
4. Wieviele Spalten haben einen numerischen Datentyp? Hinweis: Mit dem Operator `<:` (ist Untertyp von) kann eine Typbeziehung festgestellt werden. Hier ist müsste der fragliche Typ Untertyp von `Number` sein. Z.B. `Int <: Number` ergibt den Wert `true`.
5. Ermitteln Sie den Wagen mit dem kleinsten Wendekreis, der nicht in den USA produziert wurde.
"""

# ╔═╡ 73e3fe81-02f5-4e2e-9cc4-56a326cd2fd1
md"""
### Lösungen
"""

# ╔═╡ 7f2e9e13-7e23-41f6-91e2-8b028158fa69
describe(cars)

# ╔═╡ 31e94905-b989-4a4b-a0ff-2949fab15e34
unique(cars.Manufacturer)

# ╔═╡ 66730381-974e-4157-9f5a-0ea8cbfce6d7
unique(cars.Model)

# ╔═╡ 66451f11-bcd7-47f2-9ada-c75cda420ea8
sum(describe(cars)[:, :eltype] .<: Number)

# ╔═╡ 530190ed-bbd3-4f02-95a2-4c03b1ce9666
nonUSA = cars[cars.Origin .== "non-USA", :]

# ╔═╡ 253dc745-eebb-4c4e-86bd-616329bb4c17
nonUSA[nonUSA.TurnCircle .== minimum(nonUSA.TurnCircle), :]

# ╔═╡ de5fd589-3dd0-4e32-84d8-2f139e66cd04
md"""
Alternative über das Query-Package:
"""

# ╔═╡ f1de1b05-04bd-475f-9e27-74edb8d4a73b
nonUSA |> @filter(_.TurnCircle == minimum(nonUSA.TurnCircle)) |> DataFrame

# ╔═╡ 8defc76c-fc9e-4d82-84c4-d79e3e08b765
md"""
# Transformation Functions
"""

# ╔═╡ be127388-3e5d-4b3b-8d05-c15a8efe4467
md"""
Es gibt im wesentlichen drei Transformations-Funktionen:
- `combine`
- `select` (bzw. `select!`)
- `transform` (bzw. `transform!`)

Sie führen Transformationen auf einzelnen Spalten eines `DataFrame` durch und haben ein `DataFrame` zum Ergebnis.

`combine` führt aggregierende Operationen durch und hat somit typischerweise weniger Datensätze im Ergebnis-DataFrame als im Eingabe-DataFrame.

`select` und `transform` lassen die Anzahl der Datensätze unverändert. Sie erzeugen im Ergebnis-DataFrame neue Spalten. Der wesentliche Unterschied zwischen beiden Funktionen ist, dass `transform` per Default alle Spalten der Eingabe auch wieder mit ausgibt, während `select` diese per Default weglässt.

Die Varianten `select!` und `transform!` führen In-Place-Änderungen durch, während die übrigen Operationen ein neues `DataFrame` erzeugen.
"""

# ╔═╡ 0b258891-4a4e-41ba-a14a-d0a5ea3e099d
md"""
Spalten-Transformationen haben folgende Form:
- `source`: Die Quellspalte `source` wird unverändert übernommen.
- `source => target`: Die Quellspalte `source` wird in `target` umbenannt.
- `source => trans`: Die Quellspalte `source` wird mit der Operation `trans` verarbeitet und die Ergebnisspalte wird autom. generiert (inkl. Name).
- `source => trans => target`: Die Quellspalte `source` wird mit der Operation `trans` verarbeitet und das Ergebnis in der neuen Spalte `target` abgelegt.

"""

# ╔═╡ 4940a6eb-da80-4b7b-a447-e60eccf0bf2a
md"""
## `combine`
"""

# ╔═╡ 151a4041-ef37-4a3a-876d-dfaf04565270
combine(iris, :PetalLength => mean => :meanPLength)

# ╔═╡ b3e486a4-37db-4e04-af92-53426a27c38f
combine(iris, :PetalLength => mean)

# ╔═╡ 55da534b-5b69-473d-ae3e-89092f521eb3
combine(iris, :PetalLength => mean, :PetalLength => maximum)

# ╔═╡ 28ce33d8-5fa1-4409-8672-dd68874f1c5a
md"""
Die Tranformation mit den meisten Ergebniszeilen bestimmt die Zeilenzahl des Ergebnisses:
"""

# ╔═╡ 40a3c9b7-f303-4394-9d63-feee98157ca6
combine(iris, :PetalLength => mean, :PetalLength => maximum, :Species => unique)

# ╔═╡ fa6f702a-8ce8-4ed5-88a3-58f083a9e338
md"""
## `select`
"""

# ╔═╡ 31e0175f-6d2e-492c-b3e1-cca2261bb142
md"""
### Transformationen
"""

# ╔═╡ afa93896-1009-422d-aaa1-6b4a9925c11c
md"""
Eine zeilenweise Transformation (mittels `ByRow`):
"""

# ╔═╡ 07868dbb-4a12-46cb-8f90-5c02c49d3801
select(iris, :PetalLength => ByRow(sqrt) => :SqrtPL, :Species)

# ╔═╡ 636872a5-955e-409f-9fb6-631bfc951c8f
select(iris, :PetalLength => ByRow(x -> x * 2) => :DoublePL, :PetalLength, :Species)

# ╔═╡ 890e6acd-9ae4-4a5b-88e2-ae19bec66cf5
md"""
Eine anonyme Funktion als Transformation (unter Verwendung von Broadcasting):
"""

# ╔═╡ d0de1477-44ad-42a2-a647-b52ccb4fc3a2
select(iris, :PetalLength => (x -> x .* 2) => :DoublePL, :Species)

# ╔═╡ fef06885-ab99-4d91-b55c-a8af8812657f
md"""
Transformation von mehr als einer Spalte:
"""

# ╔═╡ 1c904de8-d340-4187-8c89-63f1c1eda117
select(iris, [:PetalLength, :PetalWidth] => (+) => :Psum, :Species)

# ╔═╡ 7de03670-74c0-4200-9239-5f3a3b2b3bb9
md"""
Hierbei werden die Spalten(vektoren) addiert.

Das nächste Beispiel zeigt diese Berechnung explizit:
"""

# ╔═╡ 37f387d3-d51e-494c-ae2d-d138e5d4103d
select(iris, [:PetalLength, :PetalWidth] => ((l,w) -> l + w) => :Psum, :Species)

# ╔═╡ 52161aa9-6829-43ee-941e-a21702d99025
md"""
### Selektion von Spalten
"""

# ╔═╡ 0d314253-3e32-4787-b2cf-d00226bd2bb3
select(iris, Not(:Species))

# ╔═╡ ccbdca04-dbb0-4a91-86d6-da3044541a6f
md"""
... alles ausser `Species`.

Möchte man mehrere Spalten ausblenden, muss man sie als Array an `Not` übergeben.
"""

# ╔═╡ f0ab87c9-9d92-48b7-b25a-a28671342499
select(iris, 1, 3)

# ╔═╡ 0e7dc411-0f42-4971-92c9-4d71dac0916a
md"""
... die erste und die dritte Spalte.

Oder man gibt die Spaltennamen an:
"""

# ╔═╡ 4f245a52-070e-4b30-b1bf-fd55c469ad37
select(iris, :SepalLength, :PetalLength)

# ╔═╡ 1eb0b92d-8efc-4054-8470-0e294cbff14f
select(iris, All())

# ╔═╡ 59e98893-cf1b-45dc-b5dc-d29a08c8ae20
md"""
... alle Spalten.
"""

# ╔═╡ 5d07c47b-e10d-43cb-b7bc-f525e5fb371c
select(iris, Between(:SepalLength, :PetalLength))

# ╔═╡ 296b3d9d-307c-45ec-8e4b-2ee64ace1c34
md"""
... ein Bereich von Spalten.
"""

# ╔═╡ e738752f-72c1-48a7-b749-5566e0890d25
md"""
## `transform`
"""

# ╔═╡ 6b394fa5-370c-4a3d-b8e6-06623d78b092
transform(iris, :PetalLength => (x -> x .* 2) => :DoublePL)

# ╔═╡ 290f8285-3a9b-47e0-9fe0-59b1d59f9652
md"""
# Split-Apply-Combine
"""

# ╔═╡ fbb1fc7a-1095-4370-9e5b-66af1a663fed
md"""
## Gruppieren (= Split)
"""

# ╔═╡ e535a8c8-50dc-416e-a3fc-988bf2499fc0
md"""
Über `groupby` kann ein `DataFrame` nach einem Kriterium gruppiert werden. Das Ergebnis ist ein `GroupedDataFrame`.
"""

# ╔═╡ 3622b530-9ae6-4474-8d2e-df6176603e71
g_iris = groupby(iris, :Species)

# ╔═╡ aa72339d-194e-4c86-9fb7-16ec91c3eded
size(g_iris)

# ╔═╡ b90e31b0-9d72-4872-862e-11dcf4af4d92
g_iris[1]

# ╔═╡ 86975fc3-c6ea-4d41-8364-303d8d701d1f
md"""
## Apply & Combine
"""

# ╔═╡ 0babbd5e-a11b-4181-b8ea-abfe0e2f7c56
md"""
Mit den Schritten "Apply & Combine" meint man die Anwendung von Transformationen oder (aggregierenden) Funktionen auf die gebildeten Gruppen und deren Zusammenführung in einem Ergebnis-DataFrame (combine).
"""

# ╔═╡ 7f5ef9f2-998f-4445-aa4e-aec1fb95c77e
combine(g_iris, :PetalLength => mean)

# ╔═╡ 96020635-9761-461e-bac6-df194e08e578
combine(g_iris, :PetalLength => mean, nrow)

# ╔═╡ 07239dd8-1cb2-49e6-9546-3907c7a14ec0
combine(g_iris, 1:2 => cor, nrow)

# ╔═╡ 22fa7a5b-6fd2-4ba1-9feb-d87992ceb299
combine(g_iris, [:SepalLength, :SepalWidth] => cor, nrow)

# ╔═╡ b07b3ffc-d021-48bd-9954-7d13877123a5
combine(g_iris, :PetalLength => (x -> [extrema(x)]) => [:min, :max])

# ╔═╡ 48af9544-e068-4e85-ac18-99121b8b0d2c


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DataFramesMeta = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Query = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
RDatasets = "ce6b1742-4840-55fa-b093-852dadbb1d8b"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
CSV = "~0.10.9"
DataFrames = "~1.5.0"
DataFramesMeta = "~0.13.0"
PlutoUI = "~0.7.50"
Query = "~1.0.0"
RDatasets = "~0.7.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "c8300c1097424aa1de17b3440481a70542f8edfb"

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

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "SnoopPrecompile", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "c700cce799b51c9045473de751e9319bdd1c6e94"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.9"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "5084cc1a28976dd1642c9f337b28a3cb03e0f7d2"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.7"

[[deps.Chain]]
git-tree-sha1 = "8c4920235f6c561e401dfe569beb8b924adad003"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.5.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "61fdd77467a5c3ad071ef8277ac6bd6af7dd4c04"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "aa51303df86f8626a962fccb878430cdb0a97eee"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.5.0"

[[deps.DataFramesMeta]]
deps = ["Chain", "DataFrames", "MacroTools", "OrderedCollections", "Reexport"]
git-tree-sha1 = "f9db5b04be51162fbeacf711005cb36d8434c55b"
uuid = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
version = "0.13.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

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

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IterableTables]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Requires", "TableTraits", "TableTraitsUtils"]
git-tree-sha1 = "70300b876b2cebde43ebc0df42bc8c94a144e1b4"
uuid = "1c8ee90f-4401-5389-894e-7a04a3dc0f4d"
version = "1.0.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

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

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "c272302b22479a24d1cf48c114ad702933414f80"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.5"

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

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

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

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Query]]
deps = ["DataValues", "IterableTables", "MacroTools", "QueryOperators", "Statistics"]
git-tree-sha1 = "a66aa7ca6f5c29f0e303ccef5c8bd55067df9bbe"
uuid = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
version = "1.0.0"

[[deps.QueryOperators]]
deps = ["DataStructures", "DataValues", "IteratorInterfaceExtensions", "TableShowUtils"]
git-tree-sha1 = "911c64c204e7ecabfd1872eb93c49b4e7c701f02"
uuid = "2aef5ad7-51ca-5a8f-8e88-e75cf067b44b"
version = "0.9.3"

[[deps.RData]]
deps = ["CategoricalArrays", "CodecZlib", "DataFrames", "Dates", "FileIO", "Requires", "TimeZones", "Unicode"]
git-tree-sha1 = "19e47a495dfb7240eb44dc6971d660f7e4244a72"
uuid = "df47a6cb-8c03-5eed-afd8-b6050d6c41da"
version = "0.8.3"

[[deps.RDatasets]]
deps = ["CSV", "CodecZlib", "DataFrames", "FileIO", "Printf", "RData", "Reexport"]
git-tree-sha1 = "2720e6f6afb3e562ccb70a6b62f8f308ff810333"
uuid = "ce6b1742-4840-55fa-b093-852dadbb1d8b"
version = "0.7.7"

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

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

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
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "77d3c4726515dca71f6d80fbb5e251088defe305"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.18"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

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

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableShowUtils]]
deps = ["DataValues", "Dates", "JSON", "Markdown", "Test"]
git-tree-sha1 = "14c54e1e96431fb87f0d2f5983f090f1b9d06457"
uuid = "5e66a065-1f0a-5976-b372-e0b8c017ca10"
version = "0.2.5"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Scratch", "Unicode"]
git-tree-sha1 = "a92ec4466fc6e3dd704e2668b5e7f24add36d242"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.9.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

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

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

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
# ╟─6ee75a61-9ca7-4b4d-a3c8-57d0d66f7a6e
# ╟─156d8654-bebe-4be8-b217-161f53244ed7
# ╟─ad98eefd-2d67-4419-9955-20965b6dbde0
# ╟─7f70001a-d8f3-4a5f-8be4-a301af035059
# ╟─a1a653cf-d838-4ca6-ac16-b9f5c641c1da
# ╟─3a45da57-6203-44cf-87a7-71c6225bc086
# ╠═a47ab0bc-a2a9-4e50-af77-c91fd265c4a1
# ╟─608fa022-c5d5-46b2-bbd1-721a1c00709e
# ╠═bc82b97c-60b3-424e-be89-6d9d42242742
# ╠═86bd6873-628d-4a06-919a-df7bd2c88609
# ╠═cf52a390-ba15-4b78-98b0-f4b448a64685
# ╠═ea5eead6-3ffe-4373-b6a2-a4657f5bfbf6
# ╟─55caaf85-a413-4c5a-a442-081b2f625dd7
# ╠═d0958dbc-f829-42fd-8447-add92603ff47
# ╠═0aab5dd8-6f7a-462e-b78f-a772363838b8
# ╠═9736c414-d14f-4da7-91f9-e2957864e9ba
# ╟─14057046-0a9a-459f-b00c-e48e038248fd
# ╟─c863b406-d59a-4ea1-a1b8-3e7396477fab
# ╠═6bdd5ea5-eee5-4ffa-96ea-a2c07c3b8879
# ╠═054ae231-59a3-4eae-9fa4-177f17e4358a
# ╟─ab918d79-7871-4842-8c00-50bfe15c8bec
# ╟─3258eb8e-4ce2-452f-965e-c17c95bb94f4
# ╠═8f706489-9be4-4d0c-a402-4ea9f9bed5b3
# ╠═28d57e03-bbbf-4591-b995-56dcae8c3716
# ╟─6191b590-f5fb-4fec-9818-b8d4450b20af
# ╠═14c6f59d-8145-4c1a-80fe-a89afa330e28
# ╟─50f53b95-2783-4019-a6ac-594efa2776ad
# ╠═634df5be-5bb0-4774-94e4-1e3a8eee9701
# ╟─b172e1f0-16fa-44d7-8773-ec4eebdcacc9
# ╠═dd01015e-6ec0-439a-94d8-89d7996d67f5
# ╟─202b4062-e41e-4f9f-b4d8-0cb67852b6a1
# ╟─b79487ca-098b-45dd-a9fe-807ca7e2220e
# ╠═8b44565f-4ac4-4178-ac47-feb79385d958
# ╠═e191014d-0419-427f-b1dd-b54f59bc0aa7
# ╠═ab181bb8-6990-4941-9e86-6ce28a7198dd
# ╟─7b694353-0bcc-4b7d-b36a-1c248d7227f7
# ╠═d3c7d404-b1d4-49aa-bc27-a885bf9e0f41
# ╠═2174755e-0e67-46d9-aa6d-5e1e627e7cae
# ╟─06f0ee84-2709-4451-90d9-b78136a5027a
# ╟─50ec26f7-b094-457d-bea1-65b77fabaebb
# ╟─040e3ba4-3317-4423-b20a-fe918a36a488
# ╠═75cdd729-4b79-48c8-85c9-ba595c588d60
# ╟─1cc4a162-47f7-46ca-a728-a70f3dedd807
# ╟─54c883ca-f230-41ae-810b-e24de82a7adc
# ╟─557769b4-a685-4887-b381-e82b981ecf35
# ╠═1114085d-4588-43e9-a2ea-e44a12d08d1b
# ╟─3aba39cc-c862-4a6a-ba43-9c6318a8086e
# ╟─f6b3a2d4-a892-4955-bf97-5d73e8e23aec
# ╠═9b5a1bb5-4e4e-4149-8318-6b88bb775e18
# ╠═81d71534-b2c3-4a14-bdef-eb4fed6bce92
# ╟─21a4f261-e1c9-4535-80ca-6afdd3018ed6
# ╠═2b527b3b-3c98-455b-b205-145de0209f08
# ╠═5eb955e6-1107-4d9d-915e-9d75915b8a35
# ╠═018a9ad9-f8ee-4be7-8bb0-4ff69be05760
# ╟─ffdd5b9a-cdc8-4084-8e73-791b20c790a0
# ╟─8f34a304-4a80-4a7b-a383-55ac3e06ec46
# ╟─e12c0548-8c4c-414a-96c4-bc5a225b1d2d
# ╠═8209e5f8-576d-434e-b746-9e2b74b9fdbe
# ╟─abbb00e3-a7ca-4958-9c99-6c32cedde849
# ╠═77c1f6c3-77ae-4c21-9306-bbef0878b2c7
# ╟─79e3b772-80ff-43aa-aec7-a5a19f7b5026
# ╟─3137f49c-bdef-4831-9f4f-9d4155e70bc2
# ╠═7f28ef90-9cdc-4cc0-8645-ce447a87c26b
# ╟─3a8f6c76-d660-41d4-8390-8e0fa4dc037e
# ╟─e357e7cc-494a-4b93-9838-bd4c040069d5
# ╠═8f50363d-33db-4cdb-a133-32d890d73305
# ╠═d0422cc7-81dd-4b0b-b9d2-b6e08680f76b
# ╟─e230f184-7c9a-4975-9e78-1a491b42cb4e
# ╠═5c7ba83b-2090-426e-9073-a3aebf7b7025
# ╠═118131e9-e574-4df3-ad54-e1a861aadcb5
# ╟─be96cec2-27dd-4a3b-bb5c-5a311cf8fe1e
# ╠═9c758b85-687d-4960-be8a-9faf45d48652
# ╟─1663c898-a2b9-4665-aad1-79b5426aa6ca
# ╟─508e6581-186f-4141-8926-495ed22343ea
# ╠═bf6b76b9-a87a-4cfe-b3d9-cfc832e48aaf
# ╠═4a4fe317-7e1e-47bb-96e3-9ab2a67a0356
# ╟─7de0578f-1047-42a5-b309-a92f306f629b
# ╟─76d8bafc-5cb4-4ac9-830a-0aec504d30ee
# ╠═d156eebf-312c-469c-8c84-a96698c46646
# ╟─95027329-a72d-480f-a0db-3d8c91dd6ba1
# ╠═f9f5a2d9-1dec-4a62-9c0c-d45c4ea2f448
# ╠═038a99b6-63f9-4d4f-8504-1195c93dbaea
# ╠═aa394e2b-9bba-4415-857f-87fa53eaca89
# ╟─91bfe422-0d30-43ab-beb9-3bf83f323405
# ╠═fb5b08d6-75a2-4837-9757-8b7bb3697b2a
# ╠═6ba0effe-b9f6-4768-ab09-45a58e2cb187
# ╠═040f8dc5-c962-4b76-a7e4-59cde85bd2aa
# ╟─7d7db307-4efc-4c5a-935a-5ec6823dbea6
# ╠═1f1bb4a6-00cb-4c3a-9617-6c1bfda12f8d
# ╟─d5ca3e9f-6cb8-479a-a083-41be3ca34a4c
# ╟─34756233-efe9-4bbe-836e-b4c033932e24
# ╟─147f67f2-c8c1-4b0b-a98f-7d9df56d99c8
# ╟─2a673fed-c620-4125-b475-bd3ad6683b6e
# ╠═4e47b5c1-b260-44dd-9088-a906d655c46d
# ╠═db35675e-a47b-4078-9245-dc48e6a39596
# ╟─ae1bed5b-5035-4a78-9205-d77578b47b44
# ╠═d05a9f64-85c9-413a-bac6-060e0b63b120
# ╟─39595b24-1c83-4719-bf24-8cea314fb55a
# ╟─bab94802-4c72-42ba-a23c-22efa270e3a5
# ╟─9db138e2-d87c-4266-acb4-c4ee6995e162
# ╠═295e6cd7-2ad1-4633-aae1-c7fa0236b933
# ╟─ab4c7e10-ad48-4cbf-bd4b-53b0f031a918
# ╟─64237ec9-cd5e-409c-af55-9f1fb65ae318
# ╟─3f7eecb0-e898-42ac-908e-33b008116446
# ╠═d40c393b-789f-4107-9bdd-68153001b6e7
# ╟─5dd644c3-740d-4f9e-a554-0cbf4beb0420
# ╠═80858633-2a74-4e58-b6bd-b37ef44096d6
# ╠═8edee3ed-22d6-4399-af68-3ec01f5d95c0
# ╠═ca65370a-130e-4e40-ad9b-275b1796939d
# ╟─4fb42c0b-53b7-43f0-8c09-b09a019f8713
# ╟─90bdab1f-a2af-4674-b802-a0f10c09cb0c
# ╠═1330795f-97e0-414c-8204-ccfe45c62193
# ╟─2fbce769-4082-4c93-8d3a-0762dab7ba7a
# ╟─319d9b13-8cc7-47d4-a599-57393a2a9d62
# ╟─73e3fe81-02f5-4e2e-9cc4-56a326cd2fd1
# ╠═7f2e9e13-7e23-41f6-91e2-8b028158fa69
# ╠═31e94905-b989-4a4b-a0ff-2949fab15e34
# ╠═66730381-974e-4157-9f5a-0ea8cbfce6d7
# ╠═66451f11-bcd7-47f2-9ada-c75cda420ea8
# ╠═530190ed-bbd3-4f02-95a2-4c03b1ce9666
# ╠═253dc745-eebb-4c4e-86bd-616329bb4c17
# ╟─de5fd589-3dd0-4e32-84d8-2f139e66cd04
# ╠═f1de1b05-04bd-475f-9e27-74edb8d4a73b
# ╟─8defc76c-fc9e-4d82-84c4-d79e3e08b765
# ╟─be127388-3e5d-4b3b-8d05-c15a8efe4467
# ╟─0b258891-4a4e-41ba-a14a-d0a5ea3e099d
# ╟─4940a6eb-da80-4b7b-a447-e60eccf0bf2a
# ╠═151a4041-ef37-4a3a-876d-dfaf04565270
# ╠═b3e486a4-37db-4e04-af92-53426a27c38f
# ╠═55da534b-5b69-473d-ae3e-89092f521eb3
# ╟─28ce33d8-5fa1-4409-8672-dd68874f1c5a
# ╠═40a3c9b7-f303-4394-9d63-feee98157ca6
# ╟─fa6f702a-8ce8-4ed5-88a3-58f083a9e338
# ╟─31e0175f-6d2e-492c-b3e1-cca2261bb142
# ╟─afa93896-1009-422d-aaa1-6b4a9925c11c
# ╠═07868dbb-4a12-46cb-8f90-5c02c49d3801
# ╠═636872a5-955e-409f-9fb6-631bfc951c8f
# ╟─890e6acd-9ae4-4a5b-88e2-ae19bec66cf5
# ╠═d0de1477-44ad-42a2-a647-b52ccb4fc3a2
# ╟─fef06885-ab99-4d91-b55c-a8af8812657f
# ╠═1c904de8-d340-4187-8c89-63f1c1eda117
# ╟─7de03670-74c0-4200-9239-5f3a3b2b3bb9
# ╠═37f387d3-d51e-494c-ae2d-d138e5d4103d
# ╟─52161aa9-6829-43ee-941e-a21702d99025
# ╠═0d314253-3e32-4787-b2cf-d00226bd2bb3
# ╟─ccbdca04-dbb0-4a91-86d6-da3044541a6f
# ╠═f0ab87c9-9d92-48b7-b25a-a28671342499
# ╟─0e7dc411-0f42-4971-92c9-4d71dac0916a
# ╠═4f245a52-070e-4b30-b1bf-fd55c469ad37
# ╠═1eb0b92d-8efc-4054-8470-0e294cbff14f
# ╟─59e98893-cf1b-45dc-b5dc-d29a08c8ae20
# ╠═5d07c47b-e10d-43cb-b7bc-f525e5fb371c
# ╟─296b3d9d-307c-45ec-8e4b-2ee64ace1c34
# ╟─e738752f-72c1-48a7-b749-5566e0890d25
# ╠═6b394fa5-370c-4a3d-b8e6-06623d78b092
# ╟─290f8285-3a9b-47e0-9fe0-59b1d59f9652
# ╟─fbb1fc7a-1095-4370-9e5b-66af1a663fed
# ╟─e535a8c8-50dc-416e-a3fc-988bf2499fc0
# ╠═3622b530-9ae6-4474-8d2e-df6176603e71
# ╠═aa72339d-194e-4c86-9fb7-16ec91c3eded
# ╠═b90e31b0-9d72-4872-862e-11dcf4af4d92
# ╟─86975fc3-c6ea-4d41-8364-303d8d701d1f
# ╟─0babbd5e-a11b-4181-b8ea-abfe0e2f7c56
# ╠═7f5ef9f2-998f-4445-aa4e-aec1fb95c77e
# ╠═96020635-9761-461e-bac6-df194e08e578
# ╠═07239dd8-1cb2-49e6-9546-3907c7a14ec0
# ╠═22fa7a5b-6fd2-4ba1-9feb-d87992ceb299
# ╠═b07b3ffc-d021-48bd-9954-7d13877123a5
# ╠═48af9544-e068-4e85-ac18-99121b8b0d2c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
