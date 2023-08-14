function props=getNonDefaultProps(this)






    f=fieldnames(this);
    props={};
    vhdlonlyprops={'LoopUnrolling'};
    for indx=1:length(f)
        p=findprop(this,f{indx});
        if~isequal(this.(f{indx}),p.FactoryValue)
            if strcmpi(this.TargetLanguage,'verilog')&&...
                ~isempty(strmatch(f{indx},vhdlonlyprops))

            else
                props{end+1}=f{indx};%#ok<AGROW>
            end
        end
    end


