<%@ page import="org.dbxp.moduleBase.Study; org.dbxp.moduleBase.Assay" %>
<html>
    <head>
        <meta name="layout" content="main"/>
        <title>Measurement importer</title>
        <script type="text/javascript">
			// Associative array of booleans representing the state of the
			// select boxes 
    		var selectsOK = new Array();
            var numRowSelectorProblems = 0;
            var numColumnSelectorProblems = 0;
            var layout = "${layout}";
        	
            $(document).ready(function() {
                new SelectAddMore().init({
                    rel  : 'featureSelector',
                    url  : baseUrl + '/feature/minimalCreate',
                    label   : 'Create a new feature',
                    style   : 'modify',
                    onClose : function(scope) {
						// Check the option ids of the options currently in the database
						ids = new Array();

						// Retrieve a list of all features to be put in the selects
                        $.getJSON(
                            baseUrl + "/feature/ajaxList",
                            function(data){
                                var options = '';
                                var features = data.features

                                // Create a list of options
                                for (var i = 0; i < features.length; i++) {
                                    options += '<option value="' + features[i].id + '">' + features[i].name + '</option>';
                                }
                                
                                $("select[rel*='featureSelector']").each( function( index, select ) {
                                    $select = $(select);
                                    
                                    // Update the list of items for each select. We have to keep the same values selected
                                    // so we remember the value of the selected item
                                    selection = $select.val();

                                    // Store the add/modify option
                                    var addModifyOption = $( 'option:last-child', $select );
                                    var discardOption = $( 'option:first-child', $select );

									// Check the number of features currently in the list
									var numFeatures = $( 'option', $select ).length - 2; // addModify and discard option 
                                    
									// Set the new options in the list
									$select.html( options );

                                   	// Add the add/modify and discard options back again
                                   	$select.append( addModifyOption );
									$select.prepend( discardOption );
									
									// Select the previously selected item. If nothing was selected, select the 
									// one that was added last 
									if( selection != undefined && selection != "" ) {
										// Select previously selected option
										$( 'option[value=' + selection + ']', $select ).attr( 'selected', true );
									} else if( numFeatures < features.length ){
										// Select feature last added
										$( 'option[value=' + data.last.id + ']', $select ).attr( 'selected', true );
									} else {
										// Select discard option
										$( 'option:first-child', $select ).attr( 'selected', true );
									}
                                });

                				if(layout== 'sample_layout') {
                					// Check if duplicate values are selected
            	                	selectChange('featureSelect');
                                } else {
            	                	// Check if maybe the add/modify option has been selected
									checkSelectValue('featureSelect');
                                }
                            }
                        );
                    }
                });

				if(layout== 'sample_layout') {
	                selectChange('featureSelect');
    	            selectChange('sampleSelect');
                } else {
	                selectChange('subjectSelect');
                }
            });

            function selectChange(type) {
                if(type=='featureSelect'){
                    numColumnSelectorProblems=0;
                } else {
                    numRowSelectorProblems=0;
                } // Resetting the selection problem counts per selection type

                listSelects = $( 'select.' + type );
                if(layout=="subject_layout" && type=="featureSelect") {
                    listSelects2 = $( 'select.timepointSelect');
                } else {
                    listSelects2 = null;
                }
                
                var mapSelected = new Object();
                for(i=0; i<listSelects.length; i++) {
                    val = listSelects[ i ].value;
                    if(listSelects2 != null) {
                        val2 = listSelects2[ i ].value;
                    }

					// Value is "" if 'add/modify' is selected. Value is "null" if [discard] option is selected
                    if( val!="" && val != "null" && (listSelects2 == null || val2!="null")) {
                        key = val;
                        if(listSelects2 != null) {
                            key = key + val2;
                        }
                        if(mapSelected[key]==null) {
                            mapSelected[key] = 1;
                        } else {
                            mapSelected[key]++;
                        }
                    }
                }

				var blnOK = true;
                
				// Loop through all selects and mark the ones red that have
				// been selected multiple times
                for(i=0; i<listSelects.length; i++) {
                    val = listSelects[ i ].value;
                    listSelects[ i ].style.color = '';
                    if(listSelects2 != null) {
                        val2 = listSelects2[ i ].value;
                        listSelects2[ i ].style.color = '';
                    }

                    if(val!="null" && (listSelects2 == null || val2!="null")) {
                        key = val;
                        if(listSelects2 != null) {
                            key = key + val2;
                        }
                        if(mapSelected[key] > 1 || val == "" ) {
                            listSelects[ i ].style.color = 'red';
                            if(listSelects2 != null) {
                                listSelects2[ i ].style.color = 'red';
                            }
                            blnOK = false;
                            if(type=='featureSelect'){
                                numColumnSelectorProblems++;
                            } else {
                                numRowSelectorProblems++;
                            }
                        }
                    }
                }

                selectsOK[ type ] = blnOK;

                toggleNextButton(type);
            }

            function toggleNextButton(type) {
				var globalOK = true;
				for( type in selectsOK ) {
					if( !selectsOK[ type ] ) {
						globalOK = false;
						break;
					}
				}

                $( '#_eventId_next' ).attr( 'disabled', !globalOK );
                if(!globalOK){
                    var message = "Importer cannot proceed at this moment, because the combination of values in "
                    if(numColumnSelectorProblems>0 && numRowSelectorProblems>0){
                        message += numRowSelectorProblems+" horizontal selection fields and the combination of values in "+numColumnSelectorProblems+" vertical"
                    } else {
                        if(numColumnSelectorProblems>0){
                            message += numColumnSelectorProblems+" vertical"
                        } else {
                            message += numRowSelectorProblems+" horizontal"
                        }
                    }
                    message += " selection fields are incompatible. Please review the selection fields that are marked in red."
                    $('#importerNotes').html(message);
                    $('#importerNotes').addClass("errors");
                } else {
                    $('#importerNotes').html("");
                    $('#importerNotes').removeClass("errors")
                }
            }

            function checkSelectValue(type) {
                // Loop through all selects and mark the ones red that have
				// 'Create new feature' as their selected values
                listSelects = $( 'select.' + type );
				var blnOK = true;
                for(i=0; i<listSelects.length; i++) {
                    val = listSelects[ i ].value;
                    listSelects[ i ].style.color = '';
                    if(val=="") {
                        listSelects[ i ].style.color = 'red';
                        blnOK = false;
                        if(type=='featureSelect'){
                            numColumnSelectorProblems++;
                        } else {
                            numRowSelectorProblems++;
                        }
                    }
                }
                selectsOK[ type ] = blnOK;
                toggleNextButton(type);
            }
        </script>
        
        <r:require module="importer" />
    </head>
    <body>
        <content tag="contextmenu">
            <g:render template="contextmenu" />
        </content>
        <h1>${test}</h1>
        <div class="data">

            <imp:importerHeader pages="${pages}" page="selectColumns" />

            <g:if test="${message}">
                <div class="errors">${message}</div>
                <br />
            </g:if>

            <form method="post">
                <g:if test="${subjectTimepointConflictsMessage}">
                    <div class="errors">
                        ${subjectTimepointConflictsMessage}
                        <br/>
                        <g:checkBox name="ignoreConflictedData" value="${false}"/> Ignore conflicted data.
                    </div>
                    <br />
                </g:if>

                <p>
                    You have chosen the <g:if test="${layout=='sample_layout'}">sample layout</g:if><g:if test="${layout=='subject_layout'}">subject layout</g:if>. On this page, we have tried to match your data with our data. You must double check these matches, and confirm your final choice.
                </p>
                <g:if test="${blnPassedSelectColumns==true}">
                    <p class='message'>
                        Please note: changes that have been made on the next page ('Confirm Input') are not reflected on this page. However, they will be available to you again on the next page. On this page the original file contents are being shown.
                    </p>
                </g:if>

                <%--
                    Unfortunately, within the webflow, we cannot pass variables to the view (as you do
                    normally by render( view: '', model: [...])). For that reason, we retrieve the list of
                    features from the database here. That way, if the user refreshes the page, all features
                    are read from the database (also the ones previously added).
                 --%>
                 <% features = org.dbxp.sam.Feature.list( sort: "name" ); %>


                <table style="width: auto">
                    <g:each in="${text}" var="row" status="i">
                        <g:if test="${row?.size()==0}">
                            <tr></tr>
                        </g:if>
                        <g:else>
                            <tr>
                                <g:each in="${row}" var="column" status="j">
                                    <g:if test="${!(i==0&j==0)}">
                                        <td class="${(i==0&&j>0) || (j==0) ? "importerHeader" : "importerCell"}">
                                            <div
                                            <g:if test="${column.length()>25}">
                                                 class="tooltip importerInteractiveCell">
                                                    ${column.substring(0,19)} &hellip;
                                                    <span>
                                                        ${column}
                                                    </span>
                                            </g:if>
                                            <g:else>
                                                >${column}
                                            </g:else>
                                            <g:if test="${i==0&&j>0}">
                                                <br>
                                                <!-- Feature row -->
                                                <div class="importerSelectBackground">

                                                    <select rel="featureSelector" id="${i},${j}" name="${i},${j}" class="importerSelect featureSelect" onChange="selectChange('featureSelect');">
                                                        <option value="null">[Discard]</option>
                                                        <g:each in="${features}" var="f" status="k">
                                                            <option value="${f.id}" ${feature_matches[j].equals(f.name.toLowerCase()) ? "SELECTED" : ""}>${f.name}</option>
                                                        </g:each>
                                                    </select>

                                                </div>
                                            </g:if>
                                            <g:if test="${i==1 && j>0 && layout!='sample_layout'}">
                                                <!-- Timepoint row -->
                                                <div class="importerSelectBackground">

                                                    <select rel="timepointSelector" id="${i},${j}" name="${i},${j}" class="importerSelect timepointSelect" onChange="selectChange('featureSelect');">
                                                        <option value="null">[Discard]</option>
                                                        <g:each in="${timepoints}" var="t" status="k">
                                                            <option value="${t}" ${timepoint_matches[j].equals(t.toLowerCase()) ? "SELECTED" : ""}>${t}</option>
                                                        </g:each>
                                                    </select>

                                               </div>
                                            </g:if>
                                            <g:if test="${j==0 && ((layout=='sample_layout' && i>0)||(layout!='sample_layout' && i>1))}">
                                                <br>
                                                <!-- Sample row -->
                                                <div class="importerSelectBackground">
                                                    <g:if test="${layout=='sample_layout'}">
                                                        <select rel="sampleSelector" id="${i},${j}" name="${i},${j}" class="importerSelect sampleSelect" onChange="selectChange('sampleSelect');">
                                                            <option value="null">[Discard]</option>
                                                            <g:each in="${samples}" var="s" status="k">
                                                                <option value="${s.id}" ${sample_matches[i].equals(s.name.toLowerCase()) ? "SELECTED" : ""}>${s.name}</option>
                                                            </g:each>
                                                        </select>
                                                    </g:if>
                                                    <g:else>
                                                        <select rel="subjectSelector" id="${i},${j}" name="${i},${j}" class="importerSelect subjectSelect" onChange="selectChange('subjectSelect');">
                                                            <option value="null">[Discard]</option>
                                                            <g:each in="${subjects}" var="s" status="k">
                                                                <option value="${s}" ${subject_matches[i].equals(s.toLowerCase()) ? "SELECTED" : ""}>${s}</option>
                                                            </g:each>
                                                        </select>
                                                    </g:else>
                                                </div>
                                            </g:if>
                                            </div>
                                        </td>
                                    </g:if>
                                    <g:else>
                                        <td></td>
                                    </g:else>
                                </g:each>
                            </tr>
                        </g:else>
                    </g:each>
                </table>
                <div id="importerNotes"></div>
                <imp:importerFooter>
                    <g:submitButton name="previous" value="« Previous" action="previous"/>
                    <g:submitButton name="next" value="Next »" action="next"/>
                </imp:importerFooter>
            </form>            

        </div>
    </body>
</html>