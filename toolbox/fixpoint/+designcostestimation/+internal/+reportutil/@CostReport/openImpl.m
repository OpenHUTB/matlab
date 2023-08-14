function result=openImpl(reporter,impl,varargin)




    if isempty(varargin)
        key=['E2CBpMD0QAVHCOGac3QnG83gNr4McGNDJlNM0pRb0psQ2o3VscfSuXmsMAaw'...
        ,'ZvazXBOuop5wLyAXFnAwrl3AuzA+3+1gLTKYGYr/Ms30yhjOlE/0ggZsLtJp'...
        ,'2bpbDNjDlRTleKKRhK80WdBypqDJ+iYwCksK9SKRmkPv9NhfmAM8Va6Z7NUJ'...
        ,'gcedwBbau2CDubqTx9SY2ka2A6Ssix1sDgN6qoyNZVQtoQcjPLlTQsn6atx/'...
        ,'Q6GUS50sRkFv'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end
