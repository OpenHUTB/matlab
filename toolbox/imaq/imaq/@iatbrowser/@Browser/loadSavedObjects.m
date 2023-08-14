function loadSavedObjects(this,vidObjs)







    root=this.treePanel.rootNode;

    devices=getDevices(root);
    nodeFound=[];


    for dd=1:length(devices)
        camFilesSupp=devices{dd}.CameraFileSupport;
        formats=getFormats(devices{dd});

        for fic=1:length(vidObjs)
            userData=get(vidObjs(fic).obj,'UserData');
            userData.IsSaved=true;
            set(vidObjs(fic).obj,'UserData',userData);


            if strcmp(vidObjs(fic).deviceName,devices{dd}.DeviceName)...
                &&strcmp(vidObjs(fic).adaptorName,devices{dd}.Adaptor)...
                &&strcmp(vidObjs(fic).deviceID,num2str(devices{dd}.DeviceID))
                found=false;

                for ff=1:length(formats)

                    if~strcmp(class(formats{ff}),'iatbrowser.SelectCameraFileNode')


                        if strcmp(formats{ff}.Format,vidObjs(fic).format)
                            if~isempty(formats{ff}.VideoinputObject)&&~isequal(formats{ff}.VideoinputObject,vidObjs(fic).obj)
                                delete(formats{ff}.VideoinputObject);
                            end
                            formats{ff}.VideoinputObject=vidObjs(fic).obj;
                            nodeFound=formats{ff};
                            found=true;

                            if isfield(vidObjs(fic),'sessionLog')
                                text=vidObjs(fic).sessionLog;
                            else
                                text=iatbrowser.getResourceString('RES_DESKTOP','SessionLog.LoadFailed');
                                text=sprintf('%s\nvid = videoinput(''%s'', %s, ''%s'');\nsrc = getselectedsource(vid);\n\n',...
                                text,vidObjs(fic).adaptorName,vidObjs(fic).deviceID,vidObjs(fic).format);
                            end

                            this.SessionLogPanelController.replaceText(vidObjs(fic).obj,text);

                            break;
                        end
                    end
                end



                if~found&&camFilesSupp
                    nodeFound=iatbrowser.FormatNode(devices{dd},vidObjs(fic).format,...
                    false,vidObjs(fic).obj);
                    devices{dd}.addChild(nodeFound);
                end
            end
        end
    end

    if~isempty(nodeFound)&&(length(vidObjs)==1)


        this.treePanel.currentNode=[];
        this.treePanel.selectNode(nodeFound,true);
    else
        this.treePanel.selectNode(this.treePanel.rootNode,true);
    end

    function devs=getDevices(rootNode)
        devs=rootNode.getChildren;
    end

    function forms=getFormats(deviceNode)
        forms=deviceNode.getChildren;
    end

end