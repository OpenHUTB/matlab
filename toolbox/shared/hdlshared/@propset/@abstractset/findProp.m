function y=findProp(h,varargin)




























    prop=varargin{1};
    if nargin>2
        isAll=strcmpi(varargin{2},'-all');
        if~isAll
            error(message('HDLShared:propset:unknownOption'))
        end
    else
        isAll=false;
    end
    y={};
    for i=1:numel(h.prop_sets)






        hi=h.prop_sets{i};

        allMatches=strcmpi(prop,fieldnames(hi));
        numMatches=sum(allMatches);
        if numMatches>0

            ytop=h.prop_set_names(i);
            z={};
            if isa(hi,'hdlcoderprops.PropSetAbstract')
                z=findProp(hi,varargin{:});
            else


                z=repmat({prop},1,numMatches);



            end
            if isAll

                for j=1:numMatches
                    y(end+1,:)={[ytop,z{j}]};
                end
            else

                y=[ytop,z];
                return
            end
        end
    end


