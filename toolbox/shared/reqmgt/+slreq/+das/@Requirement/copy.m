function copy(this,destObj)






    if isa(this,'slreq.das.Requirement')
        builtinProps={'Summary','Description'};
        for n=1:length(builtinProps)
            thisProp=builtinProps{n};
            destObj.(thisProp)=this.(thisProp);
        end
    end
end
