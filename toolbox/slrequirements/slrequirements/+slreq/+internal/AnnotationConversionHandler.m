classdef AnnotationConversionHandler<handle




    properties(Constant)


        Options=struct(...
        'CreateLinks',true,...
        'KeepAnnotation',false,...
        'IgnoreCallback',false,...
        'ShowMarkup',true);


        HeightMin=40;


        WidthMin=80;
    end


    methods(Static)
        function[thisReq,status,errMsg]=convert(ann,destObj,opts)






            thisReq=[];
            if nargin<3
                opts=slreq.internal.AnnotationConversionHandler.Options;
            end


            [status,errMsg]=slreq.internal.AnnotationConversionHandler.checkCompatibility(ann,opts);

            if isa(ann,'Simulink.Annotation')
                annotationObj=ann;
                modelH=bdroot(ann.Handle);
            elseif isa(ann,'Stateflow.Annotation')
                modelH=get_param(ann.Machine.Path,'Handle');
                annotationObj=ann;
            else

                annotationObj=get(ann,'Object');
                modelH=bdroot(ann);
            end

            if status
                editor=rmisl.modelEditors(modelH,true);
                if~opts.KeepAnnotation&&editor.isLocked

                    errMsg=message('Slvnv:slreq:ErrorEditorIsLockedForConversion');
                    status=false;
                end
            end

            if~status
                return;
            end

            if isa(destObj,'slreq.data.RequirementSet')
                thisReq=destObj.addRequirement;
            elseif isa(destObj,'slreq.data.Requirement')
                if destObj.isJustification
                    errMsg=message('Slvnv:slreq:ErrorAnnotationNotBeJustification');
                    status=false;
                    return;
                else
                    thisReq=destObj.addChildRequirement;
                end
            end


            summary=annotationObj.PlainText;
            lineBreak=strfind(summary,newline);
            if isempty(lineBreak)
                thisReq.summary=summary;
            else

                thisReq.summary=summary(1:lineBreak(1)-1);
            end

            text=annotationObj.Text;
            thisReq.setRawDescription(handleImages(text,modelH,thisReq));

            pos=annotationObj.Position;

            if opts.CreateLinks
                linkToDiagramOrStateflow=true;
                if~isa(ann,'Stateflow.Annotation')


                    if isa(ann,'Simulink.Annotation')
                        annHandle=ann.Handle;
                    else
                        annHandle=ann;
                    end
                    aM3IObj=SLM3I.SLDomain.handle2DiagramElement(annHandle);
                    if aM3IObj.edge.size>0

                        createdLinks=slreq.data.Link.empty;
                        for n=1:aM3IObj.edge.size


                            dstObj=aM3IObj.outEdge.at(n).dstElement;
                            createdLinks(n)=thisReq.addLink(dstObj.handle);
                        end
                        for n=1:length(createdLinks)
                            setAndShowMarkup(createdLinks(n),false);
                            linkToDiagramOrStateflow=false;
                        end
                    end
                end
                if linkToDiagramOrStateflow
                    if isa(ann,'Stateflow.Annotation')
                        linkDst=ann.getParent;
                        subviewer=ann.SubViewer;
                        if isequal(linkDst,subviewer)


                            isDiagram=true;
                        else

                            isDiagram=false;
                        end
                    else
                        linkDst=annotationObj.Parent;
                        isDiagram=true;
                    end
                    thisLink=thisReq.addLink(linkDst);
                    setAndShowMarkup(thisLink,isDiagram);
                end
            end

            if~opts.KeepAnnotation
                delete(ann);
            end

            function description=handleImages(description,modelH,dataReq)





                unpackedLocation=get_param(modelH,'UnpackedLocation');
                unpackedLocation=strrep(unpackedLocation,'\','/');


                if~isa(ann,'Stateflow.Annotation')
                    annObj=get(ann,'Object');
                else
                    annObj=ann;
                end
                images=annObj.getResourcesFiles;

                if isempty(images)

                    return;
                end

                if exist(slreq.opc.getUsrTempDir,'dir')~=7

                    mkdir(slreq.opc.getUsrTempDir)
                end


                resourceDir=fullfile(slreq.opc.getUsrTempDir,'annotations');
                if exist(resourceDir,'dir')~=7
                    mkdir(resourceDir)
                end


                for m=1:length(images)
                    thisImage=images{m};
                    copyOrig=fullfile(unpackedLocation,thisImage);
                    [~,imangeBaseName,ext]=fileparts(thisImage);
                    copyDst=fullfile(resourceDir,[imangeBaseName,ext]);

                    if exist(copyOrig,'file')~=2&&isa(ann,'Stateflow.Annotation')



                        ann.Subviewer.view;
                    end
                    copyfile(copyOrig,copyDst);

                    newImagePathInReq=['SLREQ_RESOURCE/annotations/',imangeBaseName,ext];
                    description=strrep(description,['[$unpackedFolder]',thisImage],newImagePathInReq);
                end

                dataReqSet=dataReq.getReqSet;
                dataReqSet.collectImagesFromHTML(description);
            end

            function setAndShowMarkup(thisLink,isDiagram)

                conn=thisLink.addConnector(isDiagram);
                mkup=conn.markup;

                mkup.position=[pos(1),pos(2)];
                if~isa(ann,'Stateflow.Annotation')
                    mkup.size=[pos(3)-pos(1),pos(4)-pos(2)];
                else
                    mkup.size=[pos(3),pos(4)];
                end




                if mkup.size(1)<slreq.internal.AnnotationConversionHandler.WidthMin
                    mkup.size(1)=slreq.internal.AnnotationConversionHandler.WidthMin;
                end
                if mkup.size(2)<slreq.internal.AnnotationConversionHandler.HeightMin
                    mkup.size(2)=slreq.internal.AnnotationConversionHandler.HeightMin;
                end


                mkup.visibleDetail=2;

                if opts.ShowMarkup
                    conn.isVisible=true;
                end

                dasLink=thisLink.getDasObject();
                if~isempty(dasLink)
                    if slreq.utils.isInPerspective(modelH)&&opts.ShowMarkup
                        dasLink.showConnector(isDiagram);
                    end
                end

            end
        end

        function[status,errMsg]=checkCompatibility(ann,options)

            status=true;
            errMsg=[];
            if~isscalar(ann)
                errMsg=message('Slvnv:slreq:InputMustBeAScalerHandle');
                status=false;
                return;
            end
            if~ishandle(ann)...
                ||~(isa(ann,'Stateflow.Annotation')...
                ||isa(ann,'Simulink.Annotation')...
                ||strcmp(get(ann,'type'),'annotation'))
                errMsg=message('Slvnv:slreq:AnnotationInputTypeError');
                status=false;
                return;
            end

            if~(isa(ann,'Stateflow.Annotation')||isa(ann,'Simulink.Annotation'))
                annObj=get_param(ann,'Object');
            else

                annObj=ann;
            end

            if(ischar(annObj.IsImage)&&strcmp(annObj.IsImage,'on'))...
                ||(islogical(annObj.IsImage)&&annObj.IsImage)
                errMsg=message('Slvnv:slreq:AnnotationImageNotSupported');
                status=false;
                return;
            end

            if isa(annObj,'Simulink.Annotation')
                m3iObj=SLM3I.SLDomain.handle2DiagramElement(annObj.Handle);
                if strcmp(m3iObj.Type.toString,'AREA_ANNOTATION')
                    errMsg=message('Slvnv:slreq:AnnotationAreaNotSupported');
                    status=false;
                    return;
                end
            end

            if~options.IgnoreCallback&&~isempty(annObj.ClickFcn)
                errMsg=message('Slvnv:slreq:AnnotationConversionErrorCallback');
                status=false;
                return;
            end
        end

        function menuCallback(cbinfo)





            if builtin('_license_checkout','Simulink_Requirements','quiet')

                rmi.licenseErrorDlg();
                return;
            end

            if isa(cbinfo,'GLUE2.Editor')

                m3iSelections=cbinfo.getSelection;

                selections=[];
                for n=1:m3iSelections.size
                    thisM3ISelection=m3iSelections.at(n);
                    if isa(thisM3ISelection,'SLM3I.Annotation')
                        thisSelection=get(thisM3ISelection.handle,'Object');
                        if isempty(selections)
                            selections=thisSelection;
                        else
                            selections(end+1)=thisSelection;%#ok<AGROW>
                        end
                    elseif isa(thisM3ISelection,'StateflowDI.State')&&strcmp(thisM3ISelection.Type.toString,'Note')
                        r=sfroot;
                        thisSelection=r.find('Id',thisM3ISelection.backendId);
                        if isempty(selections)
                            selections=thisSelection;
                        else
                            selections(end+1)=thisSelection;%#ok<AGROW>
                        end
                    end

                end
                diagram=cbinfo.getDiagram;
                if isa(diagram,'StateflowDI.Subviewer')
                    modelH=cbinfo.getStudio.App.blockDiagramHandle;
                else
                    modelH=bdroot(cbinfo.getDiagram.handle);
                end
            else

                selections=cbinfo.getSelection;
                modelH=cbinfo.editorModel.Handle;
            end


            appmgr=slreq.app.MainManager.getInstance();
            spObj=appmgr.getCurrentSpreadSheetObject(modelH);
            if isempty(spObj)
                co=[];
            else
                co=spObj.getCurrentSelection;
            end

            if isempty(co)...
                ||~(isa(co,'slreq.das.Requirement')||isa(co,'slreq.das.RequirementSet'))
                errordlg(getString(message('Slvnv:slreq:ConvertToRequirementNoSelectionMsg')),...
                getString(message('Slvnv:slreq:ConvertToRequirementNoSelectionTitle')),'modal');
                return;
            end


            isProcessed=false;
            failedConversion=struct('selection',{},'errMsg',{});
            for n=1:length(selections)
                if isa(selections(n),'Simulink.Annotation')||isa(selections(n),'Stateflow.Annotation')
                    if isa(selections(n),'Simulink.Annotation')
                        ann=selections(n).Handle;
                    else
                        ann=selections(n);
                    end

                    [~,status,errMsg]=slreq.internal.AnnotationConversionHandler.convert(ann,co.dataModelObj);
                    if status
                        isProcessed=true;
                    else
                        failedConversion(end+1).selection=selections(n);%#ok<AGROW> not big. 
                        failedConversion(end).errMsg=getString(errMsg);
                    end
                end
            end
            if isProcessed



                spObj=appmgr.getCurrentSpreadSheetObject(modelH);
                if~isempty(spObj)
                    spObj.setSelectedObject(co);
                end
                throwErrorForMultileAnnotations(failedConversion);
            else

                if numel(selections)>1
                    throwErrorForMultileAnnotations(failedConversion);
                else
                    throwErrorForSingleAnnotation(failedConversion);
                end
            end
        end
    end
end

function throwErrorForMultileAnnotations(failedConversion)
    if isempty(failedConversion)
        return;
    end
    emsgsToError={getString(message('Slvnv:slreq:AnnotationConversionErrorCallback')),...
    getString(message('Slvnv:slreq:ErrorEditorIsLockedForConversion')),...
    getString(message('Slvnv:slreq:ErrorAnnotationNotBeJustification'))};
    allMsgs=unique({failedConversion.errMsg});
    needErrorOut=~isempty(intersect(emsgsToError,allMsgs));
    if needErrorOut
        subMessages='';
        for n=1:length(allMsgs)
            subMessages=[subMessages,allMsgs{n},newline];%#ok<AGROW>
        end

        subMessages(end)=[];
        warndlg([getString(message('Slvnv:slreq:ConvertToRequirementWarning')),...
        subMessages],...
        getString(message('Slvnv:slreq:AnnotationInputErrorTitle')),'modal');
    end
end

function throwErrorForSingleAnnotation(failedConversion)
    errordlg(failedConversion.errMsg,...
    getString(message('Slvnv:slreq:AnnotationInputErrorTitle')),'modal');
end