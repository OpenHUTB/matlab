function parseRow(this,sigIdx,str,bCheckIfAlreadySet)



    PROPS_TO_AGGREGATE={'BlockPath'};

    props=Simulink.sdi.internal.import.MetaDataParser.getMetaDataProperties();
    for idx=1:numel(props)
        if contains(str,[props{idx},':'])

            newVal=strtrim(erase(str,[props{idx},':']));
            if strcmp(props{idx},'Name')
                this.ParsedValues(sigIdx).CustomName=newVal;
                this.ParsedValues(sigIdx).Name='<placeholder>';
            elseif any(strcmp(PROPS_TO_AGGREGATE,props{idx}))
                if isempty(this.ParsedValues(sigIdx).(props{idx}))
                    this.ParsedValues(sigIdx).(props{idx})={newVal};
                else
                    this.ParsedValues(sigIdx).(props{idx}){end+1}=newVal;
                end
            elseif~bCheckIfAlreadySet||isempty(this.ParsedValues(sigIdx).(props{idx}))
                if strcmp(props{idx},'Interp')
                    if strcmpi(newVal,'none')

                        this.ParsedValues(sigIdx).('IsEventBased')=true;
                    elseif~strcmpi(newVal,'linear')


                        this.ParsedValues(sigIdx).('IsEventBased')=false;
                        newVal='zoh';
                    end
                end
                this.ParsedValues(sigIdx).(props{idx})=newVal;
            end
            return
        end
    end
end