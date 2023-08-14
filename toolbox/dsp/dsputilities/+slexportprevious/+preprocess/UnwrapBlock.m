function UnwrapBlock(obj)







    verobj=obj.ver;
    if isR2010bOrEarlier(verobj)


        unwrapBlks=obj.findLibraryLinksTo('dspsigops/Unwrap');

        n2bReplaced=length(unwrapBlks);

        for i=1:n2bReplaced
            blk=unwrapBlks{i};
            ud=get_param(blk,'UserData');
            if(isstruct(ud)&&isfield(ud,'hasInheritedOption'))
                ud=rmfield(ud,'hasInheritedOption');
                numFields=numel(fieldnames(ud));
                if numFields==0
                    set_param(blk,'UserData','');
                else
                    set_param(blk,'UserData',ud);
                end
            end
        end

    end
