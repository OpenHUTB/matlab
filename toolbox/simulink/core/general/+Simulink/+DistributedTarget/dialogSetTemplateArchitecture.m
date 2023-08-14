classdef dialogSetTemplateArchitecture<handle







    properties
        model=[];
        explr=[];
        preValue=0;
        postValue=0;
        archFiles={'Multicore',...
        Simulink.DistributedTarget.getSupportFilePath('sampleArchitecture.xml')...
        };

        archFromConnectedTarget='archFromConnectedxPCTarget';



        supportPackages={'HCZYNQ7000','ECZYNQ7000','HDL_ALTERA_SOC','EC_ALTERA_SOC'};
        preserveCompatibleProperties=true;
    end
    methods

        function obj=dialogSetTemplateArchitecture(explr)

            obj.explr=explr;
            obj.model=explr.getRoot.ParentDiagram;

            if Simulink.DistributedTarget.isZynqSupportPackageInstalled()
                obj.archFiles{end+1}=fullfile(zynq.util.getTargetRootFolder,'+zynq','+DistributedTarget','zynq.xml');
                obj.archFiles{end+1}=fullfile(zynq.util.getTargetRootFolder,'+zynq','+DistributedTarget','zedboard.xml');
                obj.archFiles{end+1}=fullfile(zynq.util.getTargetRootFolder,'+zynq','+DistributedTarget','zc706.xml');
            end

            if Simulink.DistributedTarget.isAlteraSupportPackageInstalled()
                obj.archFiles{end+1}=fullfile(codertarget.alterasoc.internal.getSpPkgRootDir,'+codertarget','+alterasoc','+DistributedTarget','altera_cyclone_C.xml');
                obj.archFiles{end+1}=fullfile(codertarget.alterasoc.internal.getSpPkgRootDir,'+codertarget','+alterasoc','+DistributedTarget','altera_cyclone_D.xml');
                obj.archFiles{end+1}=fullfile(codertarget.alterasoc.internal.getSpPkgRootDir,'+codertarget','+alterasoc','+DistributedTarget','altera_soc_kit.xml');
            end

            customArchFiles=Simulink.DistributedTarget.CustomArchForConcurrentExecution;
            for i=1:length(customArchFiles)

                if exist(customArchFiles{i},'file')==2
                    obj.archFiles{end+1}=customArchFiles{i};
                end
            end

            if exist('isxPCTargetPresent.m','file')==2
                if isxPCTargetPresent
                    obj.archFiles{end+1}=obj.archFromConnectedTarget;
                end
            end

            obj.explr.setallactions('off');
            obj.explr.isFrozen=true;
        end

        function varType=getPropDataType(~,varName)

            if strcmp(varName,'preValue')||strcmp(varName,'postValue')
                varType='mxArray';
            elseif strcmp(varName,'preserveCompatibleProperties')
                varType='bool';
            else
                varType='other';
            end
        end

        function[desc,ID,valid]=getHeaderStringAndID(~,fileName)


            import Simulink.DistributedTarget.DistributedTargetUtils

            [xmlStruct,valid]=Simulink.DistributedTarget.parseArchXML(...
            fileName,[],true);

            if~valid,return;end

            name=DistributedTargetUtils.getArchAttribute(xmlStruct,'name');
            brief=DistributedTargetUtils.getArchAttribute(xmlStruct,'brief');
            ID=DistributedTargetUtils.getArchAttribute(xmlStruct,'uuid');
            desc=[name,' - ',brief];
        end

        function mapping=getModelMapping(obj)

            mapping=get_param(obj.model,'MappingManager');
            mapping=mapping.getActiveMappingFor('DistributedTarget');
        end

        function dlgCloseMethod(obj,~)





            try
                obj.explr.isFrozen=false;
                DeploymentDiagram.fireHierarchyChange(obj.explr.getRoot);
                DeploymentDiagram.firePropertyChange(obj.explr.getRoot);
                if((obj.preValue==obj.postValue)&&...
                    ~strcmp(obj.archFiles{obj.postValue+1},obj.archFromConnectedTarget))||...
                    (obj.postValue==length(obj.archFiles))
                    dlg=obj.explr.getDialog;
                    dlg.restoreFromSchema;
                else
                    obj.explr.tree_expandall;
                end
            catch E
                warning(E.identifier,'%s',E.message);
            end
            obj.explr.updateactions('off',obj.explr.lastSelectedNodeActions);
        end

        function dlgPostApplyMethod(obj,~)

            if obj.postValue==length(obj.archFiles)
                matlab.addons.supportpackage.internal.explorer.showSupportPackages(obj.supportPackages,...
                'tripwire');
                return;
            end

            mapping=obj.getModelMapping();
            fileName=obj.archFiles{obj.postValue+1};


            Simulink.DistributedTarget.importArchitecture(...
            mapping,fileName,obj.preserveCompatibleProperties...
            );

            dlg=obj.explr.getDialog;
            dlg.setWidgetValue('archName_tag',mapping.Architecture.Name);

        end

        function dlg=getDialogSchema(obj)


            architectureList.Name=DAStudio.message('Simulink:taskEditor:TargetArchPrompt');
            architectureList.Type='listbox';
            architectureList.ObjectProperty='postValue';
            architectureList.Mode=0;
            architectureList.MultiSelect=false;
            architectureList.Tag='architectureList';
            architectureList.MinimumSize=[450,150];

            entries={'Multicore'};
            IDs={''};
            for i=2:length(obj.archFiles)
                if strcmp(obj.archFiles{i},obj.archFromConnectedTarget)
                    entry=DAStudio.message('Simulink:taskEditor:GetArchFromxPCTargetText');
                    ID=obj.archFromConnectedTarget;
                    valid=true;
                else
                    [entry,ID,valid]=obj.getHeaderStringAndID(obj.archFiles{i});
                end

                if~valid,continue;end
                entries=[entries,{entry}];%#ok
                IDs=[IDs,{ID}];%#ok
            end

            entries=[entries...
            ,{DAStudio.message('Simulink:taskEditor:GetMoreArchText');}];
            architectureList.Entries=entries;

            actualID=obj.getModelMapping().Architecture.UUID;
            idxVec=1:length(IDs);
            idx=idxVec(strcmp(IDs,actualID));
            if isempty(idx)
                obj.preValue=-1;
                obj.postValue=0;
            else
                obj.preValue=idx-1;
                obj.postValue=idx-1;
            end


            compatibilityOpt.Type='checkbox';
            compatibilityOpt.Name='Preserve compatible properties';
            compatibilityOpt.ObjectProperty='preserveCompatibleProperties';
            compatibilityOpt.Tag='SetTemplateArchitecture_CompatibleProperties_tag';
            compatibilityOpt.Source=obj;
            compatibilityOpt.Mode=1;

            dlg.PostApplyMethod='dlgPostApplyMethod';
            dlg.PostApplyArgs={'%dialog'};
            dlg.PostApplyArgsDT={'handle'};

            dlg.CloseMethod='dlgCloseMethod';
            dlg.CloseMethodArgs={'%dialog'};
            dlg.CloseMethodArgsDT={'handle'};

            dlg.DialogTitle=DAStudio.message('Simulink:taskEditor:SelectPrompt');
            dlg.Items={architectureList,compatibilityOpt};
            dlg.IsScrollable=false;
            dlg.Sticky=true;
            pos=get(0,'ScreenSize');
            x=pos(3)/4;
            y=pos(4)/3;
            dlg.Geometry=[x,y,300,140];
            dlg.StandaloneButtonSet={'Ok','Cancel'};
        end
    end
end



