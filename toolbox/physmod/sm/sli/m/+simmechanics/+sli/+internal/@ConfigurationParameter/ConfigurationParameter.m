classdef ConfigurationParameter<handle























    properties
Name
Label
DataType
RowWithButton
Group
GroupDesc
Visible
Enabled
DefaultValue
MatlabMethod
SetFunction
Ids
    end

    methods
        function cp=ConfigurationParameter()
            mlock;
            cp.Enabled=true;
            cp.Visible=true;
            cp.Group='';
            cp.GroupDesc='';
            cp.DataType='';
            cp.RowWithButton=false;
            cp.Label='';
            cp.MatlabMethod='';
            cp.SetFunction='';
            cp.Ids={};
        end

        function set.Name(thisParam,pName)
            if isvarname(pName)
                thisParam.Name=pName;
            else
                pm_error('mech2:local:configurationparameter:InvalidName');
            end
        end

        function set.Group(thisParam,gName)
            if ischar(gName)
                thisParam.Group=gName;
            else
                pm_error('mech2:local:configurationparameter:InvalidGroup');
            end
        end

        function set.GroupDesc(thisParam,gDesc)
            if ischar(gDesc)
                thisParam.GroupDesc=gDesc;
            else
                pm_error('mech2:local:configurationparameter:InvalidGroupDesc');
            end
        end

        function set.Enabled(thisParam,isEn)
            thisParam.Enabled=simmechanics.util.checkBoolean('Enabled',isEn,true);
        end

        function set.Visible(thisParam,isVis)
            thisParam.Visible=simmechanics.util.checkBoolean('Visible',isVis,true);
        end

        function set.RowWithButton(thisParam,isRowWithBtn)
            thisParam.RowWithButton=simmechanics.util.checkBoolean(...
            'RowWithButton',isRowWithBtn,true);
        end

        function set.Label(thisParam,label)
            if ischar(label)
                thisParam.Label=label;
            else
                pm_error('mech2:local:configurationparameter:InvalidLabel');
            end
        end

        function set.Ids(thisParam,ids)
            if ischar(ids)
                thisParam.Ids={ids};
            elseif iscell(ids)
                isc=cellfun(@ischar,ids);
                if all(isc)
                    thisParam.Ids=ids;
                else
                    pm_error('mech2:local:configurationparameter:InvalidId');
                end
            else
                pm_error('mech2:local:configurationparameter:InvalidId');
            end
        end

        function set.MatlabMethod(thisParam,mMethod)
            if isempty(mMethod)
                thisParam.MatlabMethod='';
            else
                if ischar(mMethod)
                    func=which(mMethod);
                    if~isempty(func)
                        funcH=pm_pathtofunctionhandle(func);
                        if~isempty(funcH)
                            thisParam.MatlabMethod=mMethod;
                        else
                            pm_error('mech2:local:configurationparameter:InvalidMatlabMethod',mMethod);
                        end
                    else
                        pm_error('mech2:local:configurationparameter:InvalidMatlabMethod',mMethod);
                    end
                else
                    pm_error('mech2:local:configurationparameter:InvalidMatlabMethod',mMethod);
                end
            end
        end

        function set.SetFunction(thisParam,setMethod)
            if isempty(setMethod)
                thisParam.SetFunction='';
            else
                if ischar(setMethod)
                    func=which(setMethod);
                    if~isempty(func)
                        funcH=pm_pathtofunctionhandle(func);
                        if~isempty(funcH)
                            thisParam.SetFunction=setMethod;
                        else
                            pm_error('mech2:local:configurationparameter:InvalidSetFunction',setMethod);
                        end
                    else
                        pm_error('mech2:local:configurationparameter:InvalidSetFunction',setMethod);
                    end
                else
                    pm_error('mech2:local:configurationparameter:InvalidSetFunction',setMethod);
                end
            end
        end

    end
end
