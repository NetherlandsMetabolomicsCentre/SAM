<%@ page import="org.dbxp.sam.Feature" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="layout" content="main"/>
        <title>Feature ${featureInstance.name}'s properties</title>
    </head>
    <body>
        <g:hasErrors bean="${featureInstance}">
           <div class="errors">
               <g:renderErrors bean="${featureInstance}" as="list"/>
           </div>
        </g:hasErrors>
        <content tag="contextmenu">
            <li><g:link class="list" controller="feature">List features</g:link></li>
            <li><g:link class="create" controller="feature" action="create">Create new feature</g:link></li>
            <li><g:link class="import" controller="feature" action="import">Import</g:link></li>
            <li><g:link class="list" controller="featureGroup">List feature groups</g:link></li>
        </content>
        <h1>Feature ${featureInstance.name}'s properties</h1>

        <div class="data">
            <div class="dialog">
                <table class="">
                    <tbody>
                        <% def ii = 0%>
                        <g:each in="${featureInstance.giveFields()}" var="field" status="i">
                            <tr class="prop ${(i % 2) == 0 ? 'odd' : 'even'}">
                                <td valign="top">
                                    ${field.name.capitalize()}
                                </td>
                                <td valign="top" >
                                    ${featureInstance.getFieldValue(field.toString())}
                                </td>
                                <% ii = i + 1%>
                            </tr>
                        </g:each>

                        <tr class="prop  ${(ii % 2) == 0 ? 'odd' : 'even'}">
                            <td valign="top" class="name">Feature Groups</td>

                            <td valign="top" style="text-align: left;" class="value">
                                <g:each in="${org.dbxp.sam.FeaturesAndGroups.findAllByFeature(featureInstance)}" var="f" status="i">
                                    <g:link controller="featureGroup" action="show" id="${f?.featureGroup.id}">${f?.featureGroup.name.encodeAsHTML()}</g:link><br />
                                </g:each>
                            </td>

                        </tr>
                    </tbody>
                </table>
            </div>

            <ul class="data_nav buttons">
                <g:form>
                    <g:hiddenField name="id" value="${featureInstance?.id}"/>
                    <li><g:actionSubmit class="edit" action="edit" value="Edit"/></li>
                    <li><g:actionSubmit class="delete" action="delete" value="Delete" onclick="return confirm('Are you sure?');"/></li>
                    <li><g:link controller="feature" action="list" class="cancel">Back to list</g:link></li>
                </g:form>
            </ul>
        </div>
    </body>
</html>