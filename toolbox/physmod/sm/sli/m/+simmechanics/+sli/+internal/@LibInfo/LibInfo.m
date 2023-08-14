classdef LibInfo<simmechanics.sli.internal.BlockInfo























    properties
        Annotation='';
        ShowName='off';
        ShowIcon='on';
        LibFileName='';
        OrderofChildren={};
    end

    methods
        function libinfo=LibInfo()
            mlock;
            libinfo=libinfo@simmechanics.sli.internal.BlockInfo;
            libinfo.SLBlockProperties.Position=[10,10,110,50];
            libinfo.SLBlockProperties.Tag='SM2_SUBLIB';
            libinfo.SLBlockProperties.DropShadow=true;
            libinfo.SLBlockProperties.Mask=false;
            libinfo.SLBlockProperties.MaskIconFrame=true;
            libinfo.SLBlockProperties.OpenFcn='';
            libinfo.SLBlockProperties.CloseFcn='';
            libinfo.SLBlockProperties.DeleteFcn='';
            libinfo.SLBlockProperties.CopyFcn='';
        end

        function set.LibFileName(thisLibInfo,libFName)
            if isvarname(libFName)||isempty(libFName)
                thisLibInfo.LibFileName=libFName;
            else
                pm_error('sm:sli:libinfo:InvalidLibFileInfo');
            end
        end

        function set.Annotation(thisLibInfo,annot)
            if ischar(annot)
                thisLibInfo.Annotation=annot;
            else
                pm_error('sm:sli:libinfo:InvalidAnnotation');
            end
        end

        function set.ShowName(thisLibInfo,showName)
            thisLibInfo.ShowName=simmechanics.sli.internal.supported_icon_formats('ShowName',showName);
        end

        function set.ShowIcon(thisLibInfo,showIcon)
            thisLibInfo.ShowIcon=simmechanics.sli.internal.supported_icon_formats('ShowIcon',showIcon);
        end

        function set.OrderofChildren(thisLibInfo,list)
            if iscell(list)&&all(cellfun(@ischar,list))
                thisLibInfo.OrderofChildren=list;
            else
                pm_error('sm:sli:libinfo:InvalidOrderofChildren');
            end
        end

        function addPorts(~,~)

            pm_error('sm:sli:libinfo:CannotAddPorts');
        end

    end

end


