function modeout=hdlcodegenmode(modein)














    mlock;
    persistent modecache;

    if nargin==1

        switch modein
        case 'filtercoder'
            modecache=modein;

        case 'slcoder'
            modecache=modein;

        case 'reset'
            modecache=[];

        otherwise
            error(message('HDLShared:directemit:unknownmode'));

        end
    else



        if isempty(modecache)
            modecache='filtercoder';
        end
    end

    modeout=modecache;

end


