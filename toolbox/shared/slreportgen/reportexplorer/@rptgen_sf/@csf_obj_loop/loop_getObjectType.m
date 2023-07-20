function oType=loop_getObjectType(c,obj,ps)









    if nargin<2|isempty(obj)
        termTypes=listTerminalTypes(rptgen_sf.appdata_sf);
        oType='';
        numAdded=0;
        for i=1:length(termTypes)
            if get(c,['isReport',termTypes{i}])
                if numAdded==0
                    oType=termTypes{i};
                elseif numAdded>3
                    oType='Terminal';
                    return;
                else
                    oType=[oType,'/',termTypes{i}];
                end
                numAdded=numAdded+1;
            end
        end

        if numAdded==0
            oType='Terminal';
        end
    else
        oType=ps.getObjectType(obj);
    end