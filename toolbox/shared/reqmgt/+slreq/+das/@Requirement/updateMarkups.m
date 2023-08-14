function updateMarkups(this)






    markups=this.Markups;
    for n=1:length(markups)
        markups(n).update;
    end
end
