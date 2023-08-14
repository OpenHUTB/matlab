function varargout=SetNewGotoTag(BlockName,IsLibrary)





    nargoutchk(0,1);

    if IsLibrary==1

        tag='LibraryTag';
        if nargout==1
            varargout{1}=tag;
        end
    else

        a=abs(BlockName);
        x=length(a);
        tag=sprintf('T%i_%i_%6f',x,sum(a),var(a.*(1:1.3:x*1.3)));
        tag=strrep(tag,'.','');
        if nargout==1
            varargout{1}=tag;
        end

        if IsLibrary==-3

            return
        end
    end


    switch get_param(BlockName,'BlockType')
    case{'Goto','From'}
        switch get_param(bdroot(BlockName),'BlockDiagramType')
        case 'library'
        otherwise
            if~isequal(get_param(BlockName,'GotoTag'),tag)
                set_param(BlockName,'GotoTag',tag,'TagVisibility','Global');
            end
        end
    end