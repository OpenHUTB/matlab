function props=getPreferredProperties(this)


    switch this.Type
    case{'TflCustomization','TflEntry','TflTable'}
        props={'Implementation'};
    case 'TargetRegistry'
        props={'Name'};
    case 'TflRegistry'
        props={'Version'};
    otherwise
        props={'Name'};
    end
