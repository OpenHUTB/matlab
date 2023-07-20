classdef Model<handle



    properties
Name
PreCS
PostCS
Checksum
GUI
IsSelected
Status
DiffNum
Diff
ErrMessage
        ErrDlg=0
    end

    properties(Transient=true)
        Fail=false;
    end

    methods
        function h=Model(mdl,varargin)
            narginchk(1,2);

            h.GUI=true;
            if isa(mdl,'Simulink.BlockDiagram')
                h.Name=mdl.Name;
            elseif isa(mdl,'char')
                h.Name=mdl;
            end

            h.PreCS=[];
            h.PostCS=[];
            h.Checksum='';

            if nargin==2
                if strcmp(varargin{1},'nogui')
                    h.GUI=false;
                end
            end

            h.IsSelected=true;
            h.Status='Initial';
        end

        schema=getDialogSchema(h)
        schema=getSchema(h)
        setCS(h,cs,dlg)
        undoCS(h,dlg)
        redoCS(h,dlg)
        select(h,val,dlg)
        showDiff(h);
    end

end

