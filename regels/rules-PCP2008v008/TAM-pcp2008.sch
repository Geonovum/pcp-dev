<?xml version="1.0" encoding="UTF-8"?>
<!--
/*******************************************************************************
 * File: additional-validator-rules-PCP2008v007.sch
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
 * 04-09-2018	GK	PCP2008 rule de-activated in line 298. This rule was never implemented at Ruimtelijkeplannen.nl
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
	<iso:ns prefix="regexp" uri="nl.overheid.roo.util.Regexp"/>
		
    <!-- BEGIN Validaties t.b.v. Tijdelijke Alternatieve Maatregel c.q. Overgangsrecht Omgevingswet -->
    <iso:let name="identificatie" value="@gml:id"/>
    <iso:pattern id="OwTAMuitgebreid">      
      
            
            <!-- Blokkeren PCP PLANNEN -->
            <!-- Na 2024-01-01 mag voor objecttype Structuurvisieplangebied_G typePlan niet zijn 'structuurvisie'-->
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


	<iso:diagnostics>
		<iso:diagnostic id="coords"><iso:value-of select="substring(text(),0,66)"/></iso:diagnostic>
		<iso:diagnostic id="warning"></iso:diagnostic>
	</iso:diagnostics>

</iso:schema>