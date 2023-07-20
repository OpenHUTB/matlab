













classdef(Sealed=true)ModelUpdater<handle

    properties(SetAccess='private',GetAccess='protected')
        IsLibrary;
        CloseSimulink;

        Transactions;
        UpdateMsgs;
        CompileCheck;

        Prompt;
        OnlyAnalysis;


        ProductFH;
        LinkMappingFH;
        RegisteredProductFH;

        TempName;
        UpdateContext;


        MapOldMaskToCurrent;
        OldMaskTypeCell;
        OldMasksCanNotHandle;
    end

    properties(SetAccess='private',GetAccess='public')
        CheckFlags;
        CompileState;
        MyModel;

        ReplaceBlockReasonStr;
        RestoreLinkReasonStr;
        ConvertToLinkReasonStr;
        MiscUpdateReasonStr;
    end

    properties(Access='private')

        CheckData;
    end

    properties(Constant)
        PRECOMPILE=1;
        COMPILED=2;
        POSTCOMPILE=3;
        NOT_COMPILABLE=4;
        tmpLibName='muTempLib';
    end

    methods(Static)
        block2Link(curBadBlock,refstring,tempSys,varargin)
        replaceBlock(oldBlock,newBlock,varargin)
        safeSetParam(block,varargin)
        libs=findLibsInModel(mdlName)
        [report,cmdlinetext]=update(varargin)

        function cleanName=cleanLocationName(name)
            cleanName=strrep(name,sprintf('\n'),' ');
        end
    end

    methods
        function obj=ModelUpdater(varargin)
            if(nargin<1)||~ischar(varargin{1})
                DAStudio.error('SimulinkUpgradeEngine:engine:needModelName');
            end
            obj.MyModel=varargin{1};

            setDefaults(obj);
            forceSysOpen(obj);
            checkInputs(obj,nargin,varargin(2:end));

            obj.Transactions=cell2struct(cell(4,0),{'name','reason','done','functionSet'},1);
            obj.UpdateMsgs=cell2struct(cell(2,0),{'name','msg'},1);
            obj.CompileCheck=cell2struct(cell(5,0),{'block','dataCollectFH','postCompileCheckFH','fallbackFH','data'});
            generateTempName(obj);

            getRegisteredFunctions(obj);

            obj.ReplaceBlockReasonStr=DAStudio.message('SimulinkUpgradeEngine:engine:convertToNewBlock');
            obj.RestoreLinkReasonStr=DAStudio.message('SimulinkUpgradeEngine:engine:restoreLink');
            obj.ConvertToLinkReasonStr=DAStudio.message('SimulinkUpgradeEngine:engine:convertToLink');
            obj.MiscUpdateReasonStr=DAStudio.message('SimulinkUpgradeEngine:engine:miscUpdate');

            obj.CheckData=[];
        end

        function cleanup(h)
            close_system(h.TempName,0);
            if h.CloseSimulink
                close_system('simulink',0);
            end
        end

        function setDefaults(h)
            h.UpdateContext=h.MyModel;
            h.CompileState=ModelUpdater.PRECOMPILE;
            h.OnlyAnalysis=false;


            h.ProductFH={};
            h.LinkMappingFH={};
            h.RegisteredProductFH={};


            h.CheckFlags.BlockReplace=true;
            h.CheckFlags.Compiled=true;
            h.CheckFlags.LinkRestore=true;
        end

        function Prompt=getPrompt(h)
            Prompt=h.Prompt;
        end

        function h=setPrompt(h,prompt)
            h.Prompt=prompt;
        end

        function Update=doUpdate(h)
            if h.OnlyAnalysis
                Update=false;
            else
                Update=true;
            end
        end

        function context=getContext(h)
            context=h.UpdateContext;
        end

        function data=getCheckData(h,key)
            if(isfield(h.CheckData,key))
                data=h.CheckData.(key);
            else
                data=[];
            end
        end

        function setCheckData(h,key,value)
            h.CheckData.(key)=value;
        end

        function clearAllCheckData(h)
            h.CheckData=[];
        end
    end












































end


