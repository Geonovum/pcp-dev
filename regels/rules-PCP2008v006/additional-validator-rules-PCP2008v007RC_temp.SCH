<?xml version="1.0" encoding="UTF-8"?>

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
	
	<!-- Toegevoegd door LvdB 30-03-2015 -->
	<iso:pattern id="statusEnDatumChecks">
		
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
			<iso:report test="../../imro:typePlan='gemeentelijk plan; wijzigingsplan artikel 11' or ../../imro:typePlan='gemeentelijk plan; uitwerkingsplan artikel 11'">DEBUG Let op! U publiceert een plan op basis van oude wetgeving (WRO). Dit kan alleen als het moederplan als ontwerp voor 1 juli 2008 ter inzage heeft gelegen en nog actueel is.</iso:report>
			<!-- aanpassing dd. 02-05-2017 regel 5 -->
			<iso:assert test="not(../../imro:typePlan='gemeentelijk plan; voorbereidingsbesluit') ">U publiceert een plan dat juridisch gezien niet meer van toepassing is. Voorbereidingsbesluit op van basis van oude wetgeving mag na 1 juli 2008 (inwerkingtreden nieuwe Wro) niet meer.</iso:assert>
		</iso:rule>
		
	</iso:pattern>
	

	
	<iso:diagnostics>
		<iso:diagnostic id="coords"><iso:value-of select="substring(text(),0,66)"/></iso:diagnostic>
		<iso:diagnostic id="warning"></iso:diagnostic>
	</iso:diagnostics>

</iso:schema>