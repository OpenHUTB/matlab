function varargout=subcircuit2ssc(netlist,target,varargin)























    file=spiceNetlist2String(netlist);
    file=spiceSubckt.cleanNetlistStringArray(file);

    if~exist(target,'dir')
        pm_warning('physmod:ee:spice2ssc:Creating',target);
        drawnow;
        mkdir(target);
    end

    if nargin>2
        subcctName=string.empty;
        for ii=1:length(varargin)
            subcctName=[subcctName,string(varargin{ii})];%#ok<AGROW>
        end
    else
        startSubckt_index=find(strncmpi(file,spiceSubckt.startid,...
        strlength(spiceSubckt.startid)));
        subcctName=strings(size(startSubckt_index));
        for ii=1:length(startSubckt_index)
            splt=strsplit(file(startSubckt_index(ii)));
            subcctName(ii)=splt(2);
        end
    end

    subcircuitArray=spiceSubckt.empty(0,length(subcctName));
    unsupportedInfo=struct.empty(0,length(subcctName));
    if isempty(subcctName)
        pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:subcircuit2ssc:error_Netlist')),getString(message('physmod:ee:library:comments:spice2ssc:subcircuit2ssc:error_NoValidSubcircuitsFound')));
    end
    for ii=1:length(subcctName)
        subcircuitArray(ii)=spiceSubckt(file,subcctName(ii));
        subcircuitArray(ii).preparSimscapeFile(target);
        subcircuitArray(ii).writeSimscapeFile(target);
        if nargout>1
            unsupportedInfo(ii).subcircuitName=subcctName(ii);
            unsupportedInfo(ii).unsupportedCommands=subcircuitArray(ii).getAllUnsupportedData;
        end
    end

    if nargout>0
        varargout{1}=subcircuitArray;
        if nargout>1
            varargout{2}=unsupportedInfo;
        end
    end

    fprintf(1,getString(message('physmod:ee:library:comments:spice2ssc:subcircuit2ssc:sprintf_NetlistConvertedReviewSimscapeComponentFilesAndMakemanu',target)));
