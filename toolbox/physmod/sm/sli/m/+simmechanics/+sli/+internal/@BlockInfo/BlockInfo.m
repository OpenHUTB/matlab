classdef BlockInfo<handle



































































    properties
SourceFile
Hidden
IconFile
DVGIconKey
LogsData
InitialVersion
SLBlockProperties
HasDialogGraphics
    end
    properties(SetAccess=protected)
MaskParameters
Ports
ForwardingTableEntries
    end

    methods
        function blkInfo=BlockInfo()
            mlock;
            blkInfo.SLBlockProperties=pm.sli.BlockProperties;
            blkInfo.MaskParameters=pm.sli.MaskParameter.empty(1,0);
            blkInfo.Hidden='off';
            blkInfo.IconFile='';
            blkInfo.DVGIconKey='';
            blkInfo.LogsData=false;
            blkInfo.InitialVersion='UNSET';
            blkInfo.SLBlockProperties.MaskHelp=...
            'web(simmechanics.sli.internal.block_help(gcbh))';
            blkInfo.SLBlockProperties.MaskIconRotate='none';
            blkInfo.ForwardingTableEntries=...
            simmechanics.sli.internal.ForwardingTableEntry.empty;
            blkInfo.HasDialogGraphics=false;



            blkInfo.SLBlockProperties.MaskIconFrame='off';
            blkInfo.SLBlockProperties.MaskIconOpaque='off';
            blkInfo.SLBlockProperties.MaskIconUnits='normalized';


            dlgOpenCB='simmechanics.sli.internal.block_dialog(gcbh,''open'');';
            dlgCloseCB='simmechanics.sli.internal.block_dialog(gcbh,''close'');';
            blkInfo.SLBlockProperties.OpenFcn=dlgOpenCB;
            blkInfo.SLBlockProperties.CloseFcn=dlgCloseCB;
            blkInfo.SLBlockProperties.DeleteFcn=dlgCloseCB;
            blkInfo.SLBlockProperties.CopyFcn=dlgCloseCB;
        end

        function set.SourceFile(thisBlkInfo,fullFileName)
            if ischar(fullFileName)
                if~exist(fullFileName,'file')
                    pm_error('sm:sli:blockinfo:SrcFileNotExist',fullFileName);
                end
            else
                pm_error('sm:sli:blockinfo:SrcFileNotStr');
            end
            thisBlkInfo.SourceFile=strrep(fullFileName,'\','/');
        end

        function set.LogsData(thisBlkInfo,logs)
            if islogical(logs)
                thisBlkInfo.LogsData=logs;
            else
                pm_error('sm:sli:blockinfo:InvalidProp',...
                'LogsData','boolean');
            end
        end

        function set.InitialVersion(thisBlkInfo,initialVer)
            if~ischar(initialVer)
                pm_error('sm:sli:blockinfo:InitialVerNotString');
            end
            thisBlkInfo.InitialVersion=initialVer;
        end

        function set.SLBlockProperties(thisBlkInfo,slprops)
            if isa(slprops,'pm.sli.BlockProperties')
                thisBlkInfo.SLBlockProperties=slprops;
            else
                pm_error('sm:sli:blockinfo:InvalidSLProps',...
                'pm.sli.BlockProperties');
            end
        end

        function setForwardingTableEntries(thisBlkInfo,changeVer,ftEntries,varargin)
            xFormFcn='';
            if nargin==4
                xFormFcn=varargin{1};
                if~ischar(xFormFcn)
                    pm_error('sm:sli:blockinfo:InvalidProp',...
                    'Transformation Function',...
                    'string (function name)');
                end
            elseif nargin>4
                pm_error('sm:sli:blockinfo:ftEntries:InvalidNumInputs');
            end

            if ischar(ftEntries)
                ftEntry=simmechanics.sli.internal.ForwardingTableEntry;
                ftEntry.OldPath=ftEntries;
                ftEntry.XFormFunction=xFormFcn;
                ftEntry.PathChangeVersion=changeVer;
                thisBlkInfo.ForwardingTableEntries=...
                [thisBlkInfo.ForwardingTableEntries,ftEntry];
            elseif iscellstr(ftEntries)
                for idx=1:length(ftEntries)
                    ftEntry=simmechanics.sli.internal.ForwardingTableEntry;
                    ftEntry.OldPath=ftEntries{idx};
                    ftEntry.XFormFunction=xFormFcn;
                    ftEntry.PathChangeVersion=changeVer;
                    thisBlkInfo.ForwardingTableEntries=...
                    [thisBlkInfo.ForwardingTableEntries,ftEntry];
                end
            elseif isa(ftEntries,'simmechanics.sli.internal.ForwardingTableEntry')
                if nargin>3
                    pm_error('sm:sli:blockinfo:ftEntries:InvalidNumInputs');
                end
                thisBlkInfo.ForwardingTableEntries=...
                [thisBlkInfo.ForwardingTableEntries,ftEntries];
            else
                pm_error('sm:sli:blockinfo:InvalidProp','ForwardingTableEntries',...
                'simmechanics.sli.internal.ForwardingTableEntry array');
            end
        end

        function setTransformationFunction(thisBlkInfo,xFormFcn,...
            oldVer,newVer)
            ftEntry=simmechanics.sli.internal.ForwardingTableEntry;
            if ischar(xFormFcn)
                ftEntry.XFormFunction=xFormFcn;
            else
                pm_error('sm:sli:blockinfo:InvalidProp',...
                'Transformation Function',...
                'string (function name)');
            end

            if isnumeric(oldVer)&&oldVer>=0
                ftEntry.OldVersion=oldVer;
            else
                pm_error('sm:sli:blockinfo:InvalidProp','OldVersion',...
                'positive number');
            end

            if isnumeric(newVer)&&newVer>=0
                ftEntry.NewVersion=newVer;
            else
                pm_error('sm:sli:blockinfo:InvalidProp','NewVersion',...
                'positive number');
            end

            thisBlkInfo.ForwardingTableEntries=...
            [thisBlkInfo.ForwardingTableEntries,ftEntry];
        end

        function set.MaskParameters(thisBlkInfo,maskParams)
            if isa(maskParams,'pm.sli.MaskParameter')
                thisBlkInfo.MaskParameters=maskParams;
            else
                pm_error('sm:sli:blockinfo:InvalidMaskParam',...
                'pm.sli.MaskParameter');
            end
        end

        function set.Hidden(thisBlkInfo,isHidden)
            thisBlkInfo.Hidden=...
            simmechanics.util.checkBoolean('Hidden',isHidden);
        end

        function set.IconFile(thisBlkInfo,iconFile)

            if~ischar(iconFile)
                pm_error('sm:sli:blockinfo:IconFileNotStr');
            end

            if~isempty(iconFile)
                if~exist(iconFile,'file')
                    sourceFileLocation=fileparts(thisBlkInfo.SourceFile);%#ok
                    iconFile=fullfile(sourceFileLocation,iconFile);
                    if~exist(iconFile,'file')
                        pm_error('sm:sli:blockinfo:IconFileNotExist',iconFile);
                    end

                end

                [~,~,fext]=fileparts(iconFile);
                if~thisBlkInfo.isSupportedIconFormat(fext(2:end))
                    formatsCell=simmechanics.sli.internal.supported_icon_formats;
                    formats='';
                    for idx=1:length(formatsCell)
                        formats=[formats,formatsCell,','];%#ok
                    end
                    pm_error('sm:sli:blockinfo:InvalidIconFileFormat',...
                    formats(1:end-1));
                end
                iconFile=strrep(iconFile,'\','/');
            end
            thisBlkInfo.IconFile=iconFile;

        end

        function set.DVGIconKey(thisBlkInfo,dvgIconKey)
            if~ischar(dvgIconKey)
                pm_error('sm:sli:blockinfo:DVGIconKeyNotStr');
            end
            thisBlkInfo.DVGIconKey=dvgIconKey;

        end

        function set.Ports(thisBlkInfo,ports)
            if isa(ports,'simmechanics.sli.internal.PortInfo')
                thisBlkInfo.Ports=ports;
            elseif~isempty(ports)
                pm_error('sm:sli:blockinfo:InvalidPortObjects',...
                'simmechanics.sli.internal.PortInfo');
            end
        end

        function addMaskParameters(thisBlkInfo,maskParams)
            if isa(maskParams,'pm.sli.MaskParameter')
                thisBlkInfo.MaskParameters=[thisBlkInfo.MaskParameters;maskParams(:)];
            else
                pm_error('sm:sli:blockinfo:InvalidMaskParam','pm.sli.MaskParameter');
            end
        end

        function removeMaskParameter(thisBlkInfo,varnameORidx)


            if ischar(varnameORidx)

                if~isempty(thisBlkInfo.MaskParameters)
                    varNames={thisBlkInfo.MaskParameters.VarName};
                    matchIdx=strcmp(varNames,varnameORidx);
                    if~any(matchIdx)
                        pm_warning('sm:sli:blockinfo:MaskVarNotFound',varnameORidx);
                    else
                        thisBlkInfo.MaskParameters=thisBlkInfo.MaskParameters(~matchIdx);
                    end
                end
            elseif isnumeric(varnameORidx)
                if varnameORidx<=length(thisBlkInfo.MaskParameters)
                    thisBlkInfo.MaskParameters(varnameORidx)=[];
                else
                    pm_warning('sm:sli:blockinfo:MaskParamIdxExceedsLim',...
                    varnameORidx,length(thisBlkInfo.MaskParameters));
                end
            else
                pm_error('sm:sli:blockinfo:InvalidMaskParamID');
            end
        end

        function addPorts(thisBlkInfo,ports)
            if isa(ports,'simmechanics.sli.internal.PortInfo')
                thisBlkInfo.Ports=[thisBlkInfo.Ports;ports(:)];
            else
                pm_error('sm:sli:blockinfo:InvalidPortObjects','simmechanics.sli.internal.PortInfo');
            end
        end

        function removePorts(thisBlkInfo,portIdxs)
            if isnumeric(portIdxs)
                if any(portIdxs>length(thisBlkInfo.Ports))
                    pm_error('sm:sli:blockinfo:IdxExceedsNumPorts');
                else
                    thisBlkInfo.Ports(portIdxs)=[];
                end
            else
                pm_error('sm:sli:blockinfo:InvalidPortIdxs');
            end
        end

        function newBlkInfo=copy(thisBlkInfo)
            newBlkInfo=simmechanics.sli.internal.BlockInfo;
            props=fieldnames(thisBlkInfo);
            for idx=1:length(props)
                newBlkInfo.(props{idx})=thisBlkInfo.(props{idx});
            end
        end

    end

    methods(Access=protected,Hidden=true)
        function isSup=isSupportedIconFormat(thisBlkInfo,fileExt)
            if ischar(fileExt)
                isSup=any(strcmp(simmechanics.sli.internal.supported_icon_formats,fileExt));
            else
                pm_error('sm:sli:blockinfo:FileExtNotChar');
            end
        end
    end
end


