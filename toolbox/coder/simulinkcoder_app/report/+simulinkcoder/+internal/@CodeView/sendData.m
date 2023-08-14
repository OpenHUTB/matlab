function sendData(obj,uid)


    studio=obj.studio;
    if isempty(studio)
        data=obj.getCodeData();
    else
        editor=studio.App.getActiveEditor;
        cgr=coder.internal.toolstrip.util.getCodeGenRoot(editor);
        currentModel=obj.model;
        if isempty(cgr)
            topModel=currentModel;
        else
            topModel=get_param(cgr,'Name');
        end
        buildType=obj.buildType;

        mdl=currentModel;
        if isempty(buildType)

            mapping=Simulink.CodeMapping.getCurrentMapping(currentModel);
            dpType='';
            if~isempty(mapping)&&isa(mapping,'Simulink.CoderDictionary.ModelMapping')
                dpType=mapping.DeploymentType;
            end

            if strcmp(dpType,'Component')
                ref=false;
            elseif strcmp(dpType,'Subcomponent')
                ref=true;
            else



                h=get_param(currentModel,'handle');
                ref=~isequal(cgr,h);
            end
        else
            ref=strcmp(buildType,'ref');
        end

        cr=simulinkcoder.internal.Report.getInstance;
        data=cr.getCodeData(mdl,ref,topModel);
        data.review=obj.review;

        if ref&&isfield(data,'message')&&~isempty(data.message)

            cp=simulinkcoder.internal.CodePerspective.getInstance;
            if cp.isInPerspective(topModel)
                app=cp.getInfo(topModel);
                if~strcmp(app,'SimulinkCoder')
                    topT=cp.getInfo(topModel);
                    refT=cp.getInfo(currentModel);
                    if~strcmp(topT,refT)
                        refSTF=get_param(currentModel,'SystemTargetFile');
                        topSTF=get_param(topModel,'SystemTargetFile');
                        data.message=message('SimulinkCoderApp:report:ModelRefSTFNotMatch',...
                        currentModel,refSTF,topModel,topSTF).getString;
                        data.errorType='STFMismatch';
                    end
                end
            end
        end
    end

    obj.publish('init',data,uid);