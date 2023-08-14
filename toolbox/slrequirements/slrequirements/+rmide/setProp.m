function setProp(propName,sourceName,IDs,linkNo,value)


    if nargin<4
        error('Not enough arguments in a call to rmiml.setProp()');
    end




    if any(linkNo==',')
        array=textscan(linkNo,'%d','delimiter',',');
        linkNo=array{1};
        array=textscan(IDs,'%s','delimiter',',');
        IDs=array{1};
    else
        linkNo=str2num(linkNo);%#ok<ST2NM>
        IDs={IDs};
    end

    if nargin==4
        switch propName
        case 'doc'

            reqInfoStruct=rmide.getReqs(sourceName,IDs{1});
            value=rmi.chooseSameTypeDoc(reqInfoStruct(linkNo(1)),sourceName);
            if isempty(value)
                return;
            end
        otherwise
            disp(['Unsupported "Fix" call for ',propName]);
            return;
        end
    end

    switch propName
    case 'description'
        for i=1:numel(IDs)
            srcStruct=struct('domain','linktype_rmi_matlab','artifact',sourceName,'id',IDs{i});
            outLinks=slreq.outLinks(srcStruct);
            outLinks(linkNo(i)).Description=value;
        end
    case 'doc'



        for i=1:numel(IDs)
            reqInfoStruct=rmide.getReqs(sourceName,IDs{i});
            reqInfoStruct(linkNo(i)).doc=value;
            rmide.setReqs([sourceName,'|',IDs{i}],reqInfoStruct);
        end
    otherwise
        error('cannot update property %s',propName);
    end
end


