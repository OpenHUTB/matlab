function c=get(blockpath,classtype,ssid)



















    if nargin<2||isempty(classtype)
        classtype='Stateflow.Chart';
    end

    if nargin<3||isempty(ssid)
        ssid=[];
    end

    mdlname=strtok(blockpath,'/');
    h=get_param(mdlname,'Object');
    c=find(h,'-isa',classtype);
    if~isempty(c)
        x=get(c,'Path');
        c=c(i_strcmp_normalise_whitespace(char(blockpath),x));
        if numel(c)>1


            switch classtype
            case{'Stateflow.Chart','Stateflow.StateTransitionTableChart','Stateflow.ReactiveTestingTableChart'}


                s=cellfun('length',get(c,'Path'));
                c=c(s==min(s));

            case{'Stateflow.EMFunction','Stateflow.TruthTable'}

                c=c.find('ssIdNumber',ssid);
            end
        end
    end

end

function match=i_strcmp_normalise_whitespace(target,casCandidates)


    normalised_target=strcat(regexprep({target},'\s+',' '),'/');
    normalised_target=normalised_target{1};
    if~iscell(casCandidates)
        casCandidates={casCandidates};
    end
    normalised_candidates=strcat(regexprep(casCandidates,'\s+',' '),'/');





    match=strncmp(normalised_target,normalised_candidates,numel(normalised_target));
end
