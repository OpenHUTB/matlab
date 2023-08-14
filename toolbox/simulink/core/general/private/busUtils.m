function ret=busUtils(command,varargin)





    wStates=[warning;warning('query','backtrace')];
    warning off backtrace;


    try
        if nargin==0
            DAStudio.error('Simulink:utility:slUtilityBusUtilsInvalidNumInputs');
        end

        switch lower(command)
        case 'getdimsstr'
            ret=get_dims_str_l(varargin{1});
        case 'getsampletimestr'
            ret=get_sample_time_str_l(varargin{1});
        case 'getminmaxstr'
            ret=get_min_max_str_l(varargin{1});
        case 'handleunitdelaybus'
            ret=do_not_expand_unit_delay_for_buses(varargin{1});
        case 'setupgradestatus'
            set_upgrade_active_l(varargin{1},varargin{2});
        case 'strictvirtualbususage'
            ret=1;
        case 'resetprelookupbusindexdatatypefordtoprotection'
            if nargin~=3
                ret=true;
            else
                ret=reset_Prelookup_Bus_IndexDataType_ForDTOProtection(varargin{1},varargin{2});
            end
        case 'buselementsampletime'
            ret=slfeature('BusElSampleTimeDep');
        case 'physicalbusinterface'
            ret=slfeature('CUSTOM_BUSES');
        case 'ndidxbusui'
            ret=slfeature('NdIndexingBusUI');
        otherwise
            DAStudio.error('Simulink:utility:slUtilityBusUtilsInvalidCommand');
        end
    catch me
        warning(wStates);
        rethrow(me);
    end
    warning(wStates);












    function ret=reset_Prelookup_Bus_IndexDataType_ForDTOProtection(modelName,...
        busObjectName)
        ret=false;
        try
            origBusName=regexprep(busObjectName,'^dto(Dbl|Sgl|Scl)(Flt|Fxp)?_','');
            dataAccessor=Simulink.data.DataAccessor.createForExternalData(modelName);
            varId=dataAccessor.name2UniqueID(origBusName);
            tempObj=dataAccessor.getVariable(varId);
            origElemTypeStr=tempObj.Elements(1).DataType;
            expr=['fixdt(',''''...
            ,origElemTypeStr...
            ,'''',',',''''...
            ,'DataTypeOverride'...
            ,'''',',',''''...
            ,'off','''',');'
            ];
            tempObj.Elements(1).DataType=expr;
            dataAccessor.updateVariable(varId,tempObj);
        catch me
            ret=true;
        end






        function minMaxStr=get_min_max_str_l(minMaxVal)
            doublePrecision=16;
            minMaxStr=mat2str(minMaxVal,doublePrecision);






            function dimsStr=get_dims_str_l(dims)
                dimsStr=mat2str(dims);







                function tsStr=get_sample_time_str_l(ts)
                    if isinf(ts)

                        tsStr='inf';
                    elseif length(ts)==1
                        tsStr=sprintf('%.17g',ts);
                    else
                        tsStr=['[',sprintf('%.17g',ts(1)),',',sprintf('%.17g',ts(2)),']'];
                    end








                    function ret=do_not_expand_unit_delay_for_buses(val)
                        ret=slsvTestingHook('DoNotBusExpandUnitDelay',val);








                        function set_upgrade_active_l(model,onOrOff)
                            set_param(model,'ModelUpgradeActive',onOrOff);

