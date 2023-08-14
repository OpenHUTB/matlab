function[fileNames,cntThresh]=prepare_table_mapping_output(execCounts,options,varargin)







    isJustified=false;
    if 3==nargin
        isJustified=varargin{1};
    end


    fileNames={'trans.gif','grn01.gif','grn03.gif','grn05.gif',...
    'grn07.gif','grn09.gif'};

    if isJustified
        fileNames{1}='ltBlu.gif';
    end

    fileNames=strcat([options.imageSubDirectory,'/'],fileNames);
    cntThresh=determine_thresholds(execCounts,length(fileNames));

    if length(fileNames)~=(length(cntThresh)+1)
        error(message('Slvnv:simcoverage:cnt_to_filename:SizeMismatch'));
    end








    function thresh=determine_thresholds(samples,buckets)

        maxSample=max(samples(:));
        interval=maxSample/buckets;


        if interval>2
            interval=nearest_125(interval);
        else
            interval=1;
        end

        thresh=interval*(0:(buckets-2));







        function out=nearest_125(x)

            decade=ceil(log10(x));
            m=rdivide(x,power(10,decade));

            if m<0.2
                m=0.2;
            elseif m<0.5
                m=0.5;
            else
                m=1;
            end

            out=m*power(10,decade);


