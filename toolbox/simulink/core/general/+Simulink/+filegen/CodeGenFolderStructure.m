classdef CodeGenFolderStructure<Simulink.filegen.FolderSet








    enumeration



        ModelSpecific(message('Simulink:FileGen:ModelSpecificFolderSetName').getString(),...
        fullfile('slprj','sl_proj.tmw'),...
        '$(CODEGENFOLDER)',...
        '$(MODELNAME)$(NODEID)$(MDLBUILDSUFFIX)',...
        fullfile('slprj','$(STF)$(MDLREFBUILDSUFFIX)'),...
        fullfile('slprj','$(STF)$(MDLREFBUILDSUFFIX)','$(MODELNAME)'),...
        fullfile('slprj','$(STF)$(MDLREFBUILDSUFFIX)','_sharedutils')...
        );





        TargetEnvironmentSubfolder(message('Simulink:FileGen:TargetEnvironmentFolderSetName').getString(),...
        fullfile('$(TARGETENVIRONMENT)','sl.code'),...
        '$(CODEGENFOLDER)',...
        fullfile('$(TARGETENVIRONMENT)','$(MODELNAME)$(NODEID)'),...
        fullfile('$(TARGETENVIRONMENT)','_ref'),...
        fullfile('$(TARGETENVIRONMENT)','_ref','$(MODELNAME)'),...
        fullfile('$(TARGETENVIRONMENT)','_shared')...
        );
    end

    properties(Hidden,SetAccess=immutable)


        DisplayString;
    end

    methods(Access=private)
        function fileName=getMarkerFileName(this)
            [~,f,e]=fileparts(this.MarkerFile);
            fileName=[f,e];
        end
    end

    methods


        function this=CodeGenFolderStructure(displayString,...
            markerFile,...
            rootFolder,...
            modelCodeFolder,...
            targetRoot,...
            modelReferenceCodeFolder,...
            sharedUtilityCodeFolder)

            this@Simulink.filegen.FolderSet(markerFile,...
            rootFolder,...
            modelCodeFolder,...
            targetRoot,...
            modelReferenceCodeFolder,...
            sharedUtilityCodeFolder);

            this.DisplayString=displayString;
        end



        function disp(this)

            if isscalar(this)
                fprintf('''%s'' %s',this.DisplayString,...
                message('Simulink:FileGen:CodeGenFolderStructureDisplayHeader').getString);
            end

            disp@Simulink.filegen.FolderSet(this);
        end
    end

    methods(Static,Hidden)


        function default=getDefault()
            default=Simulink.filegen.CodeGenFolderStructure.ModelSpecific;
        end



        function default=getDefaultAsChar()
            default=char(Simulink.filegen.CodeGenFolderStructure.getDefault());
        end





        function value=fromString(str)
            value=Simulink.filegen.CodeGenFolderStructure(str);
        end





        function value=getEnumStringfromDisplayString(str)
            enums=enumeration('Simulink.filegen.CodeGenFolderStructure');
            value=enums(strcmp(str,{enums.DisplayString}));

            assert(isscalar(value),'Display string must be unique.');

            value=char(value);
        end



        function list=getEnumMemberDisplayList()
            list=arrayfun(@(v)v.DisplayString,enumeration('Simulink.filegen.CodeGenFolderStructure'),'UniformOutput',false);
        end



        function markerFiles=getMarkerFiles()
            markerFiles=arrayfun(@(e)e.getMarkerFileName(),...
            enumeration('Simulink.filegen.CodeGenFolderStructure'),'UniformOutput',false);
        end




        function isSelected=isSelected(codeGenFolderStructure)

            if ischar(codeGenFolderStructure)
                codeGenFolderStructure=Simulink.filegen.CodeGenFolderStructure.fromString(codeGenFolderStructure);
            end

            selectedFolderStructure=Simulink.fileGenControl('get','CodeGenFolderStructure');

            isSelected=(codeGenFolderStructure==selectedFolderStructure);
        end
    end
end
