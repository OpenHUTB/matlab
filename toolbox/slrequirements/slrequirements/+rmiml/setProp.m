function setProp(propName,sourceName,rangeIds,linkNo,value)


    if nargin<4
        error('Not enough arguments in a call to rmiml.setProp()');
    end




    if any(linkNo==',')
        array=textscan(linkNo,'%d','delimiter',',');
        linkNo=array{1};
        array=textscan(rangeIds,'%s','delimiter',',');
        rangeIds=array{1};
    else
        linkNo=str2num(linkNo);%#ok<ST2NM>
        rangeIds={rangeIds};
    end

    if nargin==4
        switch propName
        case 'doc'

            reqs1=rmiml.getReqs(sourceName,rangeIds{1});
            value=rmi.chooseSameTypeDoc(reqs1(linkNo(1)),sourceName);
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
        for i=1:numel(rangeIds)
            srcStruct=struct('domain','linktype_rmi_matlab','artifact',sourceName,'id',rangeIds{i});
            outLinks=slreq.outLinks(srcStruct);
            outLinks(linkNo(i)).Description=value;
        end
    case 'doc'



        for i=1:numel(rangeIds)
            reqs=rmiml.getReqs(sourceName,rangeIds{i});
            reqs(linkNo(i)).doc=value;
            rmiml.setReqs(reqs,sourceName,rangeIds{i});
        end
    otherwise
        error('cannot update property %s',propName);
    end
end

