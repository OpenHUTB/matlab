function result=getrandomstreamstate()




    state=RandStream.getGlobalStream.State;





    if strcmp(RandStream.getGlobalStream.Type,'legacy')
        result=[double(state{1});double(state{2});double(state{3});double(state{4});double(state{5});double(state{6})];
    else
        result=double(state);
    end

end
