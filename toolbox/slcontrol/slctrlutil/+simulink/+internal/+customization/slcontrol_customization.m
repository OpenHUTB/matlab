function slcontrol_customization()









    cm=DAStudio.CustomizationManager;

    cm.addModelAdvisorCheckFcn(@defineFrestRelatedChecks);

    cm.addModelAdvisorTaskFcn(@defineModelAdvisorTasks);




    function defineFrestRelatedChecks
        SCDFrestTimeVaryingSourceCheck;
        function taskCellArray=defineModelAdvisorTasks
            taskCellArray={};
            task=Simulink.MdlAdvisorTask;
            task.Title=ctrlMsgUtils.message('Slcontrol:frest:MdlAdvisorTaskTitle');
            task.TitleID='mathworks.slcontrolgroup';
            task.TitleTips=ctrlMsgUtils.message('Slcontrol:frest:MdlAdvisorTaskTitleTip');
            task.CheckTitleIDs={'mathworks.slcontrolfrest.timevaryingsources'};
            taskCellArray{end+1}=task;




            function SCDFrestTimeVaryingSourceCheck

                rec=ModelAdvisor.Check('mathworks.slcontrolfrest.timevaryingsources');
                rec.Title=ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesTitle');
                rec.TitleTips=ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesTitleTip');
                rec.setCallbackFcn(@findTimeVaryingSourceToReportInModelAdvisor,'None','StyleOne');
                rec.CallbackContext='PostCompile';
                rec.Visible=true;
                rec.Enable=true;
                rec.Value=false;
                rec.Group='Simulink Control Design';
                rec.CSHParameters.MapKey='ma.slcontrol';
                rec.CSHParameters.TopicID='mathworks.slcontrolfrest.timevaryingsources';
                rec.setLicense({'Simulink_Control_Design'});

                rec.setInputParametersLayoutGrid([1,1]);
                inputparam1=ModelAdvisor.InputParameter;
                inputparam1.Name=ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesInputParameter');
                inputparam1.Value='<none>';
                inputparam1.Type='string';
                inputparam1.Description=ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesInputParameterDesc');
                inputparam1.setRowSpan([1,1]);
                inputparam1.setColSpan([1,1]);
                rec.setInputParameters({inputparam1});


                mdladvRoot=ModelAdvisor.Root;
                mdladvRoot.publish(rec,rec.Group);




                function result=findTimeVaryingSourceToReportInModelAdvisor(system)
                    model=bdroot(system);
                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                    mdladvObj.setCheckResultStatus(false);

                    ModelParameterMgr=slcontrollib.internal.mdlcfg.ParameterManager(model);
                    ModelParameterMgr.loadModels;
                    models=getUniqueNormalModeModels(ModelParameterMgr);
                    io=linearize.getModelIOPoints(models);
                    if~LocalIsAnyOutputPoint(io)
                        result={LocalGetWarningIOReport()};
                        ModelParameterMgr.closeModels;
                        return;
                    end


                    varname=mdladvObj.getInputParameters;
                    varname=varname{1}.Value;
                    existingblks=[];
                    if~strcmp(varname,'<none>')
                        opts=evalinGlobalScope(model,varname);
                        if isa(opts,'frest.Frestoptions')
                            existingblks=opts.BlocksToHoldConstant;
                        else
                            ctrlMsgUtils.warning('Slcontrol:frest:MdlAdvChkFindSourcesInputParameterWarn');
                        end
                    end


                    blks=slcontrollib.internal.utils.findTimeVaryingSources(model,io);
                    if isempty(blks)

                        mdladvObj.setCheckResultStatus(true);
                        result={LocalGetPassReport()};
                        ModelParameterMgr.closeModels;
                        return;
                    end

                    if isempty(existingblks)

                        result={LocalGetBlockReport(model,blks)};
                        ModelParameterMgr.closeModels;
                        return;
                    else
                        diffblks=LocalDiffBlks(blks,existingblks);
                        if isempty(diffblks)

                            mdladvObj.setCheckResultStatus(true);
                            result={LocalGetPassReport(varname)};
                        else

                            result={LocalGetBlockReport(model,diffblks,varname)};
                        end
                    end
                    ModelParameterMgr.closeModels;






                    function bool=LocalIsAnyOutputPoint(io)
                        bool=false;
                        for ct=1:numel(io)
                            if~any(strcmp(io(ct).Type,{'input','openinput','loopbreak'}))
                                bool=true;
                                return;
                            end
                        end





                        function ft=LocalGetWarningIOReport()
                            ft=ModelAdvisor.FormatTemplate('ListTemplate');
                            setCheckText(ft,ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsInfo'));
                            ft.setSubResultStatus('Warn');
                            ft.setSubResultStatusText(ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesNoOutputIOWarn'));
                            ft.setSubBar(false);





                            function ft=LocalGetPassReport(varargin)
                                ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                setCheckText(ft,ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsInfo'));
                                ft.setSubResultStatus('Pass');
                                if nargin<1
                                    ft.setSubResultStatusText(ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsNoBlocksFound'));
                                else

                                    ft.setSubResultStatusText(ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsAllBlocksSpecified',varargin{1}));
                                end
                                ft.setSubBar(false);






                                function diffblks=LocalDiffBlks(blks,existingblks)
                                    diffblks=blks;
                                    if isempty(existingblks)
                                        return;
                                    end
                                    ind2del=[];
                                    for ct=1:numel(blks)
                                        for ctex=1:numel(existingblks)
                                            if isequal(blks(ct),existingblks(ctex))
                                                ind2del(end+1)=ct;%#ok<AGROW>
                                                break;
                                            end
                                        end
                                    end
                                    diffblks(ind2del)=[];






                                    function ft=LocalGetBlockReport(model,blks,varargin)
                                        ft=ModelAdvisor.FormatTemplate('ListTemplate');
                                        setCheckText(ft,ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsInfo'));
                                        setSubResultStatus(ft,'Warn');
                                        if nargin>2
                                            setSubResultStatusText(ft,ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFound',varargin{1}));
                                        else

                                            setSubResultStatusText(ft,ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundNoOpts'));
                                        end

                                        allblks={};
                                        for ct=numel(blks):-1:1
                                            thisblk=blks(ct).convertToCell;
                                            blockNoLineBreaks=regexprep(thisblk{end},'\n',' ');
                                            allblks{ct}=blockNoLineBreaks;
                                        end
                                        setListObj(ft,allblks);
                                        recparagraph=[ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundRecAction'),'<br/>','<br/>',...
                                        '<tt>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundCommentDefine'),'<br/>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundSampleCode1',model),'<br/>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundSampleCode2'),'<br/>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundCommentFind'),'<br/>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundSampleCode3'),'<br/>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundSampleCode4'),'<br/>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundSampleCode5'),'<br/>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundCommentRun'),'<br/>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundSampleCode6'),'<br/>',...
                                        ctrlMsgUtils.message('Slcontrol:frest:MdlAdvChkFindSourcesResultsBlocksFoundSampleCode7'),'</tt>'];
                                        setRecAction(ft,recparagraph);
                                        setSubBar(ft,false);








