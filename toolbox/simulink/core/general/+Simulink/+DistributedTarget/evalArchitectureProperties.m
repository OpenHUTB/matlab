function evalArchitectureProperties(obj)

    loc_evalArchitectureProperties(obj);

    function loc_evalArchitectureProperties(obj)



        if isa(obj,'Simulink.DistributedTarget.BaseMappingEntity')

            tmpl=obj.Template;

            if isempty(tmpl),return;end

            vals=[];
            for i=1:length(tmpl.TargetSpecificProperties)

                try
                    defn=tmpl.TargetSpecificProperties(i);
                    prop=obj.getProperty(defn.Name);

                    switch defn.getWidgetType
                    case 'checkbox'
                        if strcmpi(prop,'on')
                            vals=addValue(vals,defn.Name,true);
                        else
                            vals=addValue(vals,defn.Name,false);
                        end
                    case 'combobox'
                        vals=addValue(vals,defn.Name,0);
                        for j=1:length(defn.AllowedValues)
                            if strcmp(prop,defn.AllowedValues{j})
                                vals(end)=Simulink.DistributedTarget.EvaledProperty(defn.Name,j);
                                break;
                            end
                        end
                    case 'edit'
                        if defn.Evaluate
                            val=evalin('base',prop);
                            val=verifyAllowedValue(val);
                            vals=addValue(vals,defn.Name,val);
                        else
                            vals=addValue(vals,defn.Name,prop);
                        end
                    otherwise
                        assert(false,'Unhandled case in evalArchitectureProperties');
                    end
                catch ME
                    msgID='Simulink:mds:ParameterEvalError';
                    msg=DAStudio.message(msgID,defn.Name,obj.Name);
                    newME=MException(msgID,msg);
                    newME=newME.addCause(ME);
                    throw(newME);
                end
            end

            obj.setEvaledProperties(vals);

        else




            assert(~isprop(obj,'Template'));
        end

        function vals=addValue(vals,name,value)

            vals=[vals,Simulink.DistributedTarget.EvaledProperty(name,value)];

            function propValue=verifyAllowedValue(propValue)

                if isempty(propValue)
                    return;
                end

                if ischar(propValue)||islogical(propValue)||...
                    isreal(propValue)

                    s=size(propValue);

                    if length(s)==2
                        if s(1)==1
                            return;
                        end
                        if s(2)==1
                            propValue=propValue';
                            return;
                        end

                    end

                end

                DAStudio.error('Simulink:mds:InvalidParameterValue');

