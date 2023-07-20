function[ResultDescription,ResultHandles]=execCheckExpensiveBlock(system)







    ResultDescription={};
    ResultHandles={};


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);




    ResultDescription=addResults(@getResultsProductRounding,ResultDescription,system);
    ResultDescription=addResults(@getResultsLookupRounding,ResultDescription,system);
    ResultDescription=addResults(@getResultsDTCRounding,ResultDescription,system);
    ResultDescription=addResults(@getOtherBlocksRounding,ResultDescription,system);
    mdladvObj.setCheckResultStatus(getResultsStatus(ResultDescription));



    function results=addResults(fcn,res,fcnArgs)
        results=res;
        if nargin<3
            currentResults=fcn();
        else
            currentResults=fcn(fcnArgs);
        end
        if isempty(currentResults)
            return;
        end
        if iscell(currentResults)
            for i=1:numel(currentResults)
                results{end+1}=currentResults{i};%#ok<AGROW>
            end
        else
            results{end+1}=currentResults;
        end


        function results=getResultsProductRounding(system)

            parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_PRODUCT_ROUNDING',true,system);
            ft=ModelAdvisor.FormatTemplate('TableTemplate');
            ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckProductRounding_Title'));
            if~isempty(parsedOutput)
                ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckProductRounding'));
                ft.setSubResultStatus('warn');
                ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                DAStudio.message('ModelAdvisor:engine:FxpRndModeCol'),...
                DAStudio.message('ModelAdvisor:engine:FxpSugModeCol')});
                for idx=1:numel(parsedOutput.tag)
                    ft.addRow({parsedOutput.tag{idx}.sid,...
                    parsedOutput.tag{idx}.info('RoundingMode'),...
                    parsedOutput.tag{idx}.info('Recommended')});
                end
            else
                ft.setSubResultStatus('pass');
            end
            results=ft;


            function results=getResultsLookupRounding(system)

                parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_LOOKUP_ROUNDING',true,system);
                ft=ModelAdvisor.FormatTemplate('TableTemplate');
                ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:CheckExpensiveBlockDescLookup'));
                if~isempty(parsedOutput)
                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckLookupRounding'));
                    ft.setSubResultStatus('warn');
                    ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                    DAStudio.message('ModelAdvisor:engine:FxpRndModeCol')});
                    for idx=1:numel(parsedOutput.tag)
                        ft.addRow({parsedOutput.tag{idx}.sid,...
                        parsedOutput.tag{idx}.info('RoundingMode')});
                    end
                else
                    ft.setSubResultStatus('pass');
                end
                results=ft;


                function results=getResultsDTCRounding(system)

                    parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_DTC_ROUNDING',true,system);
                    ft=ModelAdvisor.FormatTemplate('TableTemplate');
                    ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckDTCRounding_Title'));
                    if~isempty(parsedOutput)
                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckDTCRounding'));
                        ft.setSubResultStatus('warn');
                        ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                        DAStudio.message('ModelAdvisor:engine:FxpRndModeCol'),...
                        DAStudio.message('ModelAdvisor:engine:FxpSugModeCol')});
                        for idx=1:numel(parsedOutput.tag)

                            suggestedRoundingModes=parsedOutput.tag{idx}.info('SuggestedModes');
                            ft.addRow({parsedOutput.tag{idx}.sid,...
                            parsedOutput.tag{idx}.info('RoundingMode'),...
                            suggestedRoundingModes});
                        end
                    else
                        ft.setSubResultStatus('pass');
                    end
                    results=ft;


                    function results=getOtherBlocksRounding(system)
                        results={};
                        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                        hModel=get_param(system,'Handle');


                        hBlocks=local_findSystem(hModel,'Regexp','on','RndMeth','.*');
                        hProductBlocks=local_findSystem(hBlocks,'Regexp','on','BlockType','Product');
                        hLookupBlocks=local_findSystem(hBlocks,'Regexp','on','BlockType','Lookup');
                        hDTConvBlocks=local_findSystem(hBlocks,'BlockType','DataTypeConversion');
                        hGainBlocks=local_findSystem(hBlocks,'BlockType','Gain');
                        hMathBlocks=local_findSystem(hBlocks,'BlockType','Math');
                        hBlocks=setdiff(hBlocks,hProductBlocks);
                        hBlocks=setdiff(hBlocks,hLookupBlocks);
                        hBlocks=setdiff(hBlocks,hDTConvBlocks);
                        hBlocks=setdiff(hBlocks,hGainBlocks);
                        hBlocks=setdiff(hBlocks,hMathBlocks);

                        hOtherBlocks={};


                        hBlocks=[...
                        local_findSystem(hBlocks,'RndMeth','Convergent');...
                        local_findSystem(hBlocks,'RndMeth','Round');
                        local_findSystem(hBlocks,'RndMeth','Nearest');...
                        local_findSystem(hBlocks,'RndMeth','Ceiling');...
                        local_findSystem(hBlocks,'RndMeth','Zero');...
                        ];
                        for i=1:numel(hBlocks)
                            if~isempty(mdladvObj.filterResultWithExclusion(hBlocks{i}))
                                hOtherBlocks{end+1}=hBlocks{i};%#ok<AGROW>
                            end
                        end

                        currentResult=hOtherBlocks;
                        currentDescription=ModelAdvisor.FormatTemplate('ListTemplate');
                        currentDescription.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckOtherBlocksRounding_Title'));
                        if~isempty(currentResult)
                            currentDescription.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CheckExpensiveBlockWarn1'));
                            currentDescription.setListObj(currentResult);
                            currentDescription.setSubResultStatus('warn');
                        else
                            currentDescription.setSubResultStatus('pass');
                        end
                        results{end+1}=currentDescription;



                        function status=getResultsStatus(resultSet)
                            warn=false;
                            fail=false;
                            for idx=1:numel(resultSet)
                                if strcmp(resultSet{idx}.SubResultStatus,'Warn')
                                    warn=true;
                                elseif strcmp(resultSet{idx}.SubResultStatus,'Fail')
                                    fail=true;
                                end
                            end

                            if fail
                                status=false;
                            elseif warn
                                status=false;
                            else
                                status=true;
                            end


