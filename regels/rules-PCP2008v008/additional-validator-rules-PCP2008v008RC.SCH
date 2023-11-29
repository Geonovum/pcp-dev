<?xml version="1.0" encoding="UTF-8"?>
<!--
/*******************************************************************************
 * File: additional-validator-rules-PCP2008v008RC.sch
 * (C) Logica, 2008
 *
 * Info:
 * Schematron Validation Document for PCP 2008
 *
 * History:
 * 09-12-2008   RD  Initial version
 * 02-04-2009   RD  Diagnostic information added to srsName checks.
 * 16-06-2009   RD  Use of diagnostics cause performance problems. Redefinitions and less usage of error location variables are necessary.
 * 02-06-2009   RD  Check AD11 fixed. Should prevent all heterogeneous multi geometries. Generates error instead of warning.
 * 05-01-2010   RD  Added check for presence of geometrical elements when required: AD13
 *                  Removed check AD11 (gml:MultiGeometry) because PCP2008 
 *                  plans may not contain these gml:MultiGeometry elements according to the schema.
 *                  Added check AD7(A/B) for the format of coordinates and the correct number of coordinates.
 * 14-05-2012   RD  Namespace changed because of new schema version: http://www.geonovum.nl/imro/pcp/2008/1.2
 *                  Adapted permitted document prefixes: check AD6A.
 * 30-03-2015  LvdB Added two new rules to check illegal continued reference to PDF plans after certain dates.
 * 07-06-2017  LvdB Multiple changes due to changes in regulation concerning 10-year term for updating zoningplans
 * 28-11-2023  AdB  Blokkeren PCP Plannen per 1-1-2024
 ******************************************************************************/

Opmerkingen / hints:

-->
<iso:schema xmlns:iso="http://purl.oclc.org/dsdl/schematron"
			xml:lang="en">  <!-- ISO Schematron 1.6 namespace -->

	<!-- <iso:title>Schematron validaties voor PCP2008</iso:title>-->
	<!-- Titel weggehaald om geen output te hebben als er geen fout is -->
	<!-- De validator concludeert daaruit dat er geen fout en dus een valide bestand is -->

	<iso:ns prefix="gml" uri="http://www.opengis.net/gml"/>
	<iso:ns prefix="imro" uri="http://www.geonovum.nl/imro/pcp/2008/1.2"/>
	<iso:ns prefix="regexp" uri="nl.vrom.roo.util.Regexp"/>
		
	<iso:let name="lowercaseChars" value="'abcdefghijklmnopqrstuvwxyz'"/>
	<iso:let name="uppercaseChars" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	
	<!-- Vrijwel identiek aan schematron validaties voor IMRO2006 -->	
	
	<!-- Definieer reguliere expressies om PlanIdn en bestandsnamen te valideren -->

	<iso:let name="ankerRegexp" value="'(#.*)?'"/>
	
	<iso:let name="idnCheckRegexp" value="'NL\.IMRO\.[0-9]{8}[A-Za-z0-9_\-\.]{1,15}-'"/>

	<iso:let name="extensionCheckRegexp" value="'\.pdf'"/>

	<iso:let name="coordinaatFormat" value="'-?[0-9]{1,6}(\.[0-9]{0,3})?'"/>
	<iso:let name="space" value="'[ \t\r\n\v\f]+'"/>
	

	<!-- detectedPlanId is nodig voor extra bestandsnaamvalidatie: planId moet in bestandsnaam voorkomen. -->
	<iso:let name="detectedPlanId" value="//*[imro:typePlan]/imro:identificatie"/>
	<iso:let name="detectedPlanType" value="//imro:typePlan"/>


	<iso:let name="isBestemmingsplan" value="contains('gemeentelijk plan; bestemmingsplan artikel 10,
														gemeentelijk plan; uitwerkingsplan artikel 11,
														gemeentelijk plan; wijzigingsplan artikel 11', $detectedPlanType)"/>
	
	<iso:pattern name="Idn_Check">
		<iso:rule context="//*[imro:typePlan]/imro:identificatie">
			<iso:let name="identificatie" value="text()"/>

			<iso:assert test="regexp:matches($identificatie,$idnCheckRegexp)">
Foutcode AD1: imro:identificatie (huidige waarde "<iso:value-of select="$identificatie"/>") 
voldoet niet aan de conventies van STRI2006 voor plan identificatie 
(PlanIdn regexp: '<iso:value-of select="$idnCheckRegexp"/>')
			</iso:assert>
		</iso:rule>
		
	</iso:pattern>

	<!-- 1 patch is toegestaan volgens het schema. Hierbinnen moet 1 polygonPatch afgedwongen worden. -->
	<iso:pattern name="plangebied_num_patches_eq_1_Check">
		<iso:rule context="//*[imro:typePlan]/imro:geometrie//gml:Surface">
			
			<iso:let name="numOfPolygonPatches" value="count(gml:patches/gml:PolygonPatch)"/>

			<iso:assert test="$numOfPolygonPatches = 1">
Foutcode AD2: Binnen een plangebied is er binnen een gml:surface element 1 gml:patches element toegestaan en
daarin 1 gml:PolygonPatch element toegestaan (huidig aantal=<iso:value-of select="$numOfPolygonPatches"/>)
			</iso:assert>
		</iso:rule>
		
	</iso:pattern>



	<iso:pattern name="SRSCheck">
		<iso:rule context="//*[@srsName]">
			<iso:assert test="@srsName = 'urn:ogc:def:crs:EPSG::28992'">
Foutcode AD3A: srsName (huidige waarde "<iso:value-of select="@srsName"/>") moet gelijk zijn aan urn:ogc:def:crs:EPSG::28992.
			</iso:assert>
		</iso:rule>

		<iso:rule context="//gml:posList">

			<iso:assert test="ancestor::*[@srsName]" diagnostics="coords">
Foutcode AD3B: Geen srsName aanwezig voor geometrisch element <iso:value-of select="name()"/>. 
Eerste coordinaten zijn: <iso:value-of select="substring(text(),0,66)"/>
			</iso:assert>
		</iso:rule>
	</iso:pattern>

	<iso:pattern name="DatumCheck">

		<iso:rule context="//imro:datum">
		
			<iso:let name="matchesDateFormat" value="regexp:matches(.,'[0-9]{4}-[0-9]{2}-[0-9]{2}')"/>
		
			 <iso:assert test="$matchesDateFormat">
Foutcode AD4A: De datum <iso:value-of select="name()"/>  (huidige waarde "<iso:value-of select="text()"/>") moet formaat jjjj-mm-dd hebben.
			</iso:assert>

			<iso:let name="century" value="substring(text(),1,2)"/>
			<iso:let name="year" value="substring(text(),1,4)"/>
			<iso:let name="month" value="substring(text(),6,2)"/>
			<iso:let name="day" value="substring(text(),9,2)"/>
			
			<!--
				Datum regels:
					Eeuw = 19 of 20.
					1 <= Maand <=12.
					1 <= dag.
					Maanden met 31 dagen: 01,03,05,07,08,10 of 12.
					Maanden met 30 dagen: 04,06,09 of 11.
					Februari: dag <=28, of als schrikkeljaar (jaar modulo 4 = 0) dan dag <= 29.
												
					Hierbij is gebruik gemaakt van de booleaanse algebraregel: 
					!A + AB =!A + B   ofwel:  Not(A) or (A and B) = Not(A) or B
					
					Als er niet aan het datumformaat voldaan is dan wordt de volgende constructie als geldig 
					beschouwd. In dat geval is de fout namelijk al boven gerapporteerd en hoeft er niet in
					detail te worden gekeken. 
			 -->
			
			<iso:assert test="not($matchesDateFormat) or 
								(
									($century=19 or $century=20) and 
									(($month &lt;=12) and ($month &gt;= 1)) and
									($day &gt;= 1) and 
									( not(contains('01,03,05,07,08,10,12',$month)) or ($day &lt;=31) ) and
									( not(contains('04,06,09,11',$month)) or ($day &lt;= 30) ) and 
									( not($month=2) or ($day &lt;=28) or (($day &lt;= 29 ) and ($year mod 4 = 0)) )
								)">
Foutcode AD4B: De datum <iso:value-of select="name()"/>  (huidige waarde "<iso:value-of select="text()"/>") is geen geldige datum.
			</iso:assert>
			
		</iso:rule>
	</iso:pattern>
	
	<iso:pattern name="OverheidsCode4DigitsCheck">
		<iso:rule context="//imro:overheidsCode">
			<iso:assert test="regexp:matches(.,'[0-9]{4}')">
Foutcode AD5: overheidsCode (huidige waarde "<iso:value-of select="text()"/>") moet uit 4 cijfers bestaan. 
			</iso:assert>
		</iso:rule>
	</iso:pattern>


	<iso:pattern name="verwijzingNaarTekst">

		<!-- Abstracte regel die 2x gebruikt wordt.
			Verondersteld wordt dat variabel bestandsprefixenRegexp bekend is gemaakt met een iso:let instructie -->	
		<iso:rule abstract="true" id="verwijzingNaarTekstCheck">

			<iso:let name="bestandsnaamRegexp" value="concat($bestandsprefixenRegexp,$idnCheckRegexp,$extensionCheckRegexp,$ankerRegexp)"/>

			<iso:let name="bestandsnaamMatchesRegexp" value="regexp:matches(.,$bestandsnaamRegexp)"/>
		
			<iso:assert test="$bestandsnaamMatchesRegexp">
Foutcode AD6A: verwijzingNaarTekst (huidige waarde "<iso:value-of select="text()"/>") is een bestandsnaam 
die niet voldoet aan de bestandsnaamconventies van PCP2008 en STRI2006 voor planType '<iso:value-of select="$detectedPlanType"/>' 
(Reguliere expressie: <iso:value-of select="$bestandsnaamRegexp"/>)
			</iso:assert>
		
			<iso:let name="bestandsnaamNaPrefix" value="substring-after(.,'_')"/>
			<iso:let name="bestandsnaamNaPrefixBegintMetPlanId" value="starts-with($bestandsnaamNaPrefix, $detectedPlanId)"/>
			
			<!-- 
				Als de bestandsnaam niet aan de reguliere expressie voor bestandsnamen 
				voldoet wordt deze test overgeslagen. 
				
				Gebruik wordt gemaakt van booleanse expressie: !A + AB = !A + B
			 -->
			<iso:assert test="not($bestandsnaamMatchesRegexp) 
													or $bestandsnaamNaPrefixBegintMetPlanId">
Foutcode AD6B: verwijzingNaarTekst (huidige waarde "<iso:value-of select="text()"/>") is een bestandsnaam 
die niet voldoet aan de bestandsnaamconventies van PCP2008 en STRI2006. 
De planId (<iso:value-of select="$detectedPlanId"/>) volgt niet onmiddelijk na de prefix. 
			</iso:assert>
		</iso:rule>

<!-- 		
		<!- - Alle verwijzingen naar tekst worden gecheckt in het geval dat plantype = gemeentelijk plan; voorbereidingsbesluit - ->
		<iso:rule context="//imro:verwijzingNaarTekst[$detectedPlanType = 'gemeentelijk plan; voorbereidingsbesluit']">

			<!- - Binnen PCP2008 zijn slechts 2 prefixen toegestaan bij plantype gelijk aan gemeentelijk plan; voorbereidingsbesluit. - ->
			<iso:let name="bestandsprefixenRegexp" value="'(p|bd)_'"/>
			<iso:extends rule="verwijzingNaarTekstCheck"/>
		</iso:rule>

		<!- - Alle verwijzingen naar tekst worden gecheckt in het geval van overige plantypes (!= gemeentelijk plan; voorbereidingsbesluit) - ->
		<iso:rule context="//imro:verwijzingNaarTekst[$detectedPlanType != 'gemeentelijk plan; voorbereidingsbesluit']">

			<!- - Binnen PCP2008 zijn slechts 3 prefixen toegestaan voor plantype ongelijk gemeentelijk plan; voorbereidingsbesluit. - ->
			<iso:let name="bestandsprefixenRegexp" value="'(p|v|t)_'"/>
			<iso:extends rule="verwijzingNaarTekstCheck"/>
		</iso:rule>
-->

		

		<!-- Alle verwijzingen naar tekst worden gecheckt in het geval dat plantype = bestemmingsplan --> 
		<iso:rule context="//imro:verwijzingNaarTekst[$isBestemmingsplan]">

			<!-- Binnen PCP2008 zijn slechts 6 prefixen toegestaan bij plantype bestemmingsplan --> 
			<iso:let name="bestandsprefixenRegexp" value="'(p|v|vb|t|tb|bd)_'"/>
			<iso:extends rule="verwijzingNaarTekstCheck"/>
		</iso:rule>

			<!-- Alle verwijzingen naar tekst worden gecheckt in het geval dat plantype = beleidsplan --> 
		<iso:rule context="//imro:verwijzingNaarTekst[not($isBestemmingsplan)]">

			<!-- Binnen PCP2008 zijn slechts 4 prefixen toegestaan bij plantype beleidsplan-->
			<iso:let name="bestandsprefixenRegexp" value="'(p|d|db|bd)_'"/>
			<iso:extends rule="verwijzingNaarTekstCheck"/>
		</iso:rule>

	</iso:pattern>

 
	<iso:pattern name="check_coordinates">

		<iso:rule context="//gml:posList | //gml:pos | //gml:lowerCorner | //gml:upperCorner">
			<!-- Convert all white space characters into single space characters -->
			
			<iso:let name="coordinates" value="normalize-space(text())"/>
			<iso:let name="coords" value="substring($coordinates,0,66)"/>
 
			<!-- Try to tokenize the coordinates string and match every coordinate to an expression --> 
  			<iso:assert test="regexp:matchesAfterTokenize($coordinates,$coordinaatFormat,$space)" diagnostics="coords">
Foutcode AD7A: Coördinaten binnen <iso:value-of select="name()"/> moeten getallen zijn van maximaal 3 decimalen na de decimale komma, waarbij
meerdere exemplaren gescheiden zijn door lege ruimten. Afwijking binnen element <iso:value-of select="ancestor::*[@gml:id][1]/@gml:id"/>.
Eerste coordinaten zijn: <iso:value-of select="$coords"/>
			</iso:assert>

 
			<iso:let name="aantal" value="regexp:tokenCount($coordinates,$space)"/>
			
			<iso:assert test="(2 * floor($aantal div 2) = $aantal) and ($aantal > 0)" diagnostics="coords">
Foutcode AD7B: Coördinaten binnen <iso:value-of select="name()"/> komen niet in het juiste aantal voor. 
Verwacht wordt dat dit een even aantal coördinaten ( &gt; 0 ) is, geconstateerd aantal is <iso:value-of select="$aantal"/>. Afwijking binnen element <iso:value-of select="ancestor::*[@gml:id][1]/@gml:id"/>.
Eerste coordinaten zijn: <iso:value-of select="$coords"/>
			</iso:assert>

		</iso:rule>
		
	</iso:pattern>

	<iso:pattern name="check_for_geometrical_elements_present_when_required">
		<!--
			Het is de bedoeling dat er geen lege geometrische elementen zullen zijn.
			Het is ook de bedoeling dat geometrische elementen coördinaten bevatten.
			Het XML schema van gml4nl staat helaas bij sommige typen toe dat er helemaal niets 
			in zo'n element zit. Dit is alleen het geval bij een gml:MultiSurface.
			
			gml:patches wordt getest door check AD2. Zou hier slechts een extra foutmelding geven.
		 -->
		<iso:rule context="gml:MultiSurface | gml:PolygonPatch">

			<!-- Geometrical child elements need to be present here. -->
			<iso:assert test="(.//gml:*)">
Foutcode AD13: <iso:name/> dient een geometrische inhoud te hebben.
			</iso:assert>
		</iso:rule>
	</iso:pattern>

	<!-- Toegevoegd door LvdB 30-03-2015 -->
	<iso:pattern name="statusEnDatumChecks">
		
		<iso:rule context="//imro:PlanstatusEnDatum_PCP">
			
			<iso:let name="century" value="substring(imro:datum/text(),1,2)"/>
			<iso:let name="year" value="substring(imro:datum/text(),1,4)"/>
			<iso:let name="month" value="substring(imro:datum/text(),6,2)"/>
			<iso:let name="day" value="substring(imro:datum/text(),9,2)"/>
			<iso:let name="concatenatedDate" value="concat($year,$month,$day)"/>
			
			<iso:assert test="not(imro:planstatus='vastgesteld') or (imro:planstatus='vastgesteld' and $concatenatedDate &lt; '20150701')">
				Foutcode AD4C: een plancontour en PDF (plan conform PRPCP2008) moet vastgesteld zijn vóór 1 juli 2015. 				
			</iso:assert>
			
			<!--Deze waarschuwing verwijderd per 07-06-2017.  Door het vervallen van de actualiseringsplicht onder voorwaarde dat er een planversie aanwezig is in RPnl, moeten ook oudere plannen van voor de Nieuwe Wet ruimtelijke ordening alsnog worden toegelaten. Eerder konden we die wel tegenhouden.
				<iso:report test="imro:planstatus='vastgesteld' and not($concatenatedDate&gt;20100101
				and $concatenatedDate&lt;20150701) and not($concatenatedDate&gt;20150701)">Let op: een geladen plancontour en PDF (plan conform PRPCP2008) moet een vaststellingsdatum tussen 1 januari 2010 en 1 juli 2015 hebben.</iso:report>-->
			
			<!-- Toegevoegd door LvdB 07-06-2017 -->
			<!-- aanpassing dd. 02-05-2017 regel 1 -->
			<iso:assert test="not(../../imro:typePlan='gemeentelijk plan; bestemmingsplan artikel 10') or ../../imro:typePlan='gemeentelijk plan; bestemmingsplan artikel 10' and (imro:planstatus='vastgesteld' or imro:planstatus='onherroepelijk')">Een bestemmingsplan artikel 10 WRO mag uitsluitend de planstatus ‘onherroepelijk of vastgesteld’ hebben</iso:assert>
			<!-- aanpassing dd. 02-05-2017 regel 2 -->
			<iso:assert test="not(../../imro:typePlan='gemeentelijk plan; bestemmingsplan artikel 10') or ../../imro:typePlan='gemeentelijk plan; bestemmingsplan artikel 10' and ($concatenatedDate &lt; 20170102)">Een bestemmingsplan artikel 10 WRO kan niet meer met deze datum worden gepubliceerd; controleer de vaststellingsdatum of datum onherroepelijk</iso:assert>
			<!-- aanpassing dd. 02-05-2017 regels 3 en 4 -->
			<iso:report test="../../imro:typePlan='gemeentelijk plan; wijzigingsplan artikel 11' or ../../imro:typePlan='gemeentelijk plan; uitwerkingsplan artikel 11'">Let op! U publiceert een plan op basis van oude wetgeving (WRO). Dit kan alleen als het moederplan als ontwerp voor 1 juli 2008 ter inzage heeft gelegen en nog actueel is.</iso:report>
			<!-- aanpassing dd. 02-05-2017 regel 5 -->
			<iso:assert test="not(../../imro:typePlan='gemeentelijk plan; voorbereidingsbesluit') ">U publiceert een plan dat juridisch gezien niet meer van toepassing is. Voorbereidingsbesluit op van basis van oude wetgeving mag na 1 juli 2008 (inwerkingtreden nieuwe Wro) niet meer.</iso:assert>
		</iso:rule>
		
	</iso:pattern>	
	
	<!--
		  _                _             ____        _______       __  __       _ _             _              _     _  
		 | |              (_)           / __ \      |__   __|/\   |  \/  |     (_) |           | |            (_)   | | 
		 | |__   ___  __ _ _ _ __      | |  | |_      _| |  /  \  | \  / |_   _ _| |_ __ _  ___| |__  _ __ ___ _  __| | 
		 | '_ \ / _ \/ _` | | '_ \     | |  | \ \ /\ / / | / /\ \ | |\/| | | | | | __/ _` |/ _ \ '_ \| '__/ _ \ |/ _` | 
		 | |_) |  __/ (_| | | | | |    | |__| |\ V  V /| |/ ____ \| |  | | |_| | | || (_| |  __/ |_) | | |  __/ | (_| | 
		 |_.__/ \___|\__, |_|_| |_|     \____/  \_/\_/ |_/_/    \_\_|  |_|\__,_|_|\__\__, |\___|_.__/|_|  \___|_|\__,_| 
		              __/ |                                                           __/ |                             
		             |___/                                                           |___/                              
	-->
	
	<!-- BEGIN Validaties t.b.v. Tijdelijke Alternatieve Maatregel c.q. Overgangsrecht Omgevingswet -->
	<iso:let name="identificatie" value="@gml:id"/>
	<iso:pattern id="OwTAMuitgebreid">      
		
		
		<!-- Blokkeren PCP PLANNEN -->
		<!-- Na 2024-01-01 mag objecttype Plangebied_PCP niet van elk typePlan zijn.-->
		<iso:rule context="//imro:Plangebied_PCP[imro:typePlan = *]">
			<iso:assert
				test="                
				number(translate(imro:planstatusInfo/imro:PlanstatusEnDatum_PCP/imro:datum, '-', '')) &lt; 20240101
				"> 
				IMRO-object met gml:id <iso:value-of select="@gml:id"/>, 
				type = <iso:value-of select="name()"/>: 
				Fout in Plangebied_PCP -> Als Plangebied_PCP, dan mag datum niet groter zijn dan of gelijk aan 2024-01-01. 
			</iso:assert>
		</iso:rule>
		
		
	</iso:pattern>
	
	<!-- 
		       _           _            ____        _______       __  __       _ _             _              _     _  
		      (_)         | |          / __ \      |__   __|/\   |  \/  |     (_) |           | |            (_)   | | 
		   ___ _ _ __   __| | ___     | |  | |_      _| |  /  \  | \  / |_   _ _| |_ __ _  ___| |__  _ __ ___ _  __| | 
		  / _ \ | '_ \ / _` |/ _ \    | |  | \ \ /\ / / | / /\ \ | |\/| | | | | | __/ _` |/ _ \ '_ \| '__/ _ \ |/ _` | 
		 |  __/ | | | | (_| |  __/    | |__| |\ V  V /| |/ ____ \| |  | | |_| | | || (_| |  __/ |_) | | |  __/ | (_| | 
		  \___|_|_| |_|\__,_|\___|     \____/  \_/\_/ |_/_/    \_\_|  |_|\__,_|_|\__\__, |\___|_.__/|_|  \___|_|\__,_| 
		                                                                             __/ |                             
		                                                                            |___/                                                    
	-->
	
	

	
	<iso:diagnostics>
		<iso:diagnostic id="coords"><iso:value-of select="substring(text(),0,66)"/></iso:diagnostic>
		<iso:diagnostic id="warning"></iso:diagnostic>
	</iso:diagnostics>

</iso:schema>