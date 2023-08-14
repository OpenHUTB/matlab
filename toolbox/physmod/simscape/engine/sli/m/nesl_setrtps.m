function nesl_setrtps(sd,ids,vals)





    if isempty(ids)
        assert(isempty(vals))

        sd.setParameters([],[],[],[]);
        return
    end


    [vl,vi,vj,vr]=nesl_setrtpvalues(sd.ParameterInfo,ids,vals);


    sd.setParameters(vl,vi,vj,vr);
end
