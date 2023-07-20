function pathItems=getPathItems(h,blkObj)%#ok




    pathItems={'Weights',...
    'Product output W''u',...
    'Product output Q*u',...
    'Accumulator W''u'};





















    blkAlgorithm=blkObj.Algo;

    if strcmpi(blkAlgorithm,'LMS')||strcmpi(blkAlgorithm,'Sign-Data LMS')

        pathItems{end+1}='Product output mu*e';

    elseif strcmpi(blkAlgorithm,'Normalized LMS')

        pathItems{end+1}='Product output u''u';
        pathItems{end+1}='Product output mu*e';
        pathItems{end+1}='Accumulator u''u';
        pathItems{end+1}='Quotient';

    end




    pathItems{end+1}='Output Signal';
    pathItems{end+1}='Error Signal';
