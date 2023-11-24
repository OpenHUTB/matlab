function[addTocurrent,f,isCalledFromDesktop]=privateDeterminePlotBehavior(tag)


    isCalledFromDesktop=false;

    if(isempty(get(0,'children')))
        addTocurrent=false;
        f=figure('Tag',tag);
    else
        f=gcf;
        if(ishold)
            switch get(f,'Tag')
            case tag
                addTocurrent=true;
            otherwise
                addTocurrent=false;
                f=figure('Tag',tag);
            end
        else
            addTocurrent=false;
            f=figure('Tag',tag);
        end
    end

