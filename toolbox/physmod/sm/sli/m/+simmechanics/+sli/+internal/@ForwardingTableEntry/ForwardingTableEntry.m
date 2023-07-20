classdef ForwardingTableEntry<handle
















    properties
OldPath
NewPath
OldVersion
NewVersion
PathChangeVersion
XFormFunction
    end

    methods
        function ftEntry=ForwardingTableEntry()
            mlock;
            ftEntry.OldPath='';
            ftEntry.NewPath='';
            ftEntry.OldVersion=0.0;
            ftEntry.NewVersion=1.0;
            ftEntry.PathChangeVersion='UNSET';
            ftEntry.XFormFunction='';
        end

        function set.OldPath(thisFtEntry,oldPath)
            if ischar(oldPath)
                thisFtEntry.OldPath=oldPath;
            else
                pm_error('sm:sli:blockinfo:InvalidProp','OldPath',...
                'string');
            end
        end

        function set.NewPath(thisFtEntry,newPath)
            if ischar(newPath)
                thisFtEntry.NewPath=newPath;
            else
                pm_error('sm:sli:blockinfo:InvalidProp','NewPath',...
                'string');
            end
        end

        function set.OldVersion(thisFtEntry,oldVer)
            if isnumeric(oldVer)&&(oldVer>=0)
                thisFtEntry.OldVersion=oldVer;
            end
        end

        function set.NewVersion(thisFtEntry,newVer)
            if isnumeric(newVer)&&(newVer>=0)
                thisFtEntry.NewVersion=newVer;
            end
        end

        function set.PathChangeVersion(thisFtEntry,chVer)
            if ischar(chVer)
                thisFtEntry.PathChangeVersion=chVer;
            end
        end

        function set.XFormFunction(thisFtEntry,xfFunc)
            if ischar(xfFunc)
                thisFtEntry.XFormFunction=xfFunc;
            else
                pm_error('sm:sli:blockinfo:InvalidProp','XFormFunction',...
                'string');
            end
        end

        function slEntry=getSlParameterValueEntry(thisFtEntry)
            oldPath=strrep(thisFtEntry.OldPath,sprintf('\n'),' ');
            newPath=strrep(thisFtEntry.NewPath,sprintf('\n'),' ');
            if isempty(thisFtEntry.XFormFunction)
                if strcmp(oldPath,newPath)
                    oldv=num2str(thisFtEntry.OldVersion,'%4.2f');
                    newv=num2str(thisFtEntry.NewVersion,'%4.2f');
                    slEntry={oldPath,newPath,...
                    oldv,newv};
                else
                    slEntry={oldPath,newPath};
                end
            else
                if strcmp(oldPath,newPath)
                    oldv=num2str(thisFtEntry.OldVersion,'%4.2f');
                    newv=num2str(thisFtEntry.NewVersion,'%4.2f');
                    slEntry={oldPath,newPath,...
                    oldv,newv,thisFtEntry.XFormFunction};
                else
                    slEntry={oldPath,newPath,...
                    thisFtEntry.XFormFunction};
                end
            end
        end

        function newEntry=copy(thisFtEntry)
            newEntry=simmechanics.sli.internal.ForwardingTableEntry;
            props=fieldnames(thisFtEntry);
            for idx=1:length(props)
                newEntry.(props{idx})=thisFtEntry.(props{idx});
            end
        end

    end

end
