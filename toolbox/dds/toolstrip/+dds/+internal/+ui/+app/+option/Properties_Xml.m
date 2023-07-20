



classdef Properties_Xml<dds.internal.ui.app.base.OptionBase
    methods
        function obj=Properties_Xml(env)





            id='Properties_Xml';
            obj@dds.internal.ui.app.base.OptionBase(id,env);

            obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardXmlFiles');

            obj.DepInfo=struct('Option','Properties_Import','Value',true);
            obj.Indent=1;

            obj.Type='file';
            obj.Answer='';
            obj.resetValue();
        end

        function resetValue(obj)
            obj.Value=struct();
            obj.Value.file=[];
            obj.Value.folder='';
            obj.Value.browse='xmlSelect';
        end

        function msg=getOptionMessage(obj)
            if(obj.Env.VendorSupportsIDLAndXML)
                obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardIDLXmlFiles');
            else
                obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardXmlFiles');
            end
            msg=obj.OptionMessage;
        end

        function setAnswer(obj,value)
            if~obj.isEnabled||isempty(value)
                return;
            end
            value=strtrim(value);
            obj.Answer=true;
            obj.resetValue();
            if contains(value,'" "')
                splitStr=strsplit(value,'" "');
                if numel(splitStr)>1
                    obj.Value.folder={};
                    for i=1:numel(splitStr)

                        if startsWith(splitStr{i},'"')&&~endsWith(splitStr{i},'"')
                            splitStr{i}=[splitStr{i},'"'];
                        end
                        if endsWith(splitStr{i},'"')&&~startsWith(splitStr{i},'"')
                            splitStr{i}=['"',splitStr{i}];
                        end
                        val=splitStr{i};
                        if startsWith(val,'"')&&endsWith(val,'"')
                            [folder,fileN,fext]=fileparts(val(2:end-1));
                        else
                            [folder,fileN,fext]=fileparts(val);
                        end
                        obj.Value.file{i}=[fileN,fext];
                        if~endsWith(folder,filesep)
                            folder=[folder,filesep];%#ok<AGROW>
                        end
                        obj.Value.folder{i}=folder;
                    end
                    return;
                end
            end
            if startsWith(value,'"')&&endsWith(value,'"')
                [folder,fileN,fext]=fileparts(value(2:end-1));
            else
                [folder,fileN,fext]=fileparts(value);
            end
            obj.Value.file{1}=[fileN,fext];
            if~endsWith(folder,filesep)
                folder=[folder,filesep];
            end
            obj.Value.folder={};
            obj.Value.folder{1}=folder;
        end

        function ret=onNext(obj)


            ret=0;
            if isempty(obj.Value.file)

                return
            end
            files=fullfile(obj.Value.folder,obj.Value.file);
            if isempty(files)
                ret=-1;
                errordlg(DAStudio.message('dds:toolstrip:uiWizardXmlEmptyError'),...
                obj.Env.Gui.Title,'replace');
                return
            end
            obj.Env.start_spin();
            c=onCleanup(@()obj.Env.stop_spin());
            try
                if~isempty(obj.Env.DDConn)
                    hasDDSpart=Simulink.DDSDictionary.ModelRegistry.hasDDSPart(obj.Env.DDConn.filepath);
                    if hasDDSpart
                        existingModel=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(obj.Env.DDConn.filepath);
                        clonedModel=dds.internal.simulink.Util.cloneModel(existingModel);
                        ddConn=dds.internal.simulink.Util.importDDSXml(files,obj.Env.DDConn.filepath,obj.Env.VendorKey,clonedModel);
                    else
                        ddConn=dds.internal.simulink.Util.importDDSXml(files,obj.Env.DDConn.filepath,obj.Env.VendorKey);
                    end
                else
                    ddConn=dds.internal.simulink.Util.importDDSXml(files,'',obj.Env.VendorKey);
                end
            catch ex

                ret=-1;




                errordlg(ex.message,...
                obj.Env.Gui.Title,'replace');
                return
            end
            obj.Env.DDConn=ddConn;
            obj.Env.ImportProperties=true;
        end

    end
end


