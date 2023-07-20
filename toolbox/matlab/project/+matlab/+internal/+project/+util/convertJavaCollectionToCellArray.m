function result=convertJavaCollectionToCellArray(javaCollection,elementConverter)














    if nargin<2

        elementConverter=@(x)x;
    end

    size=javaCollection.size();

    result=cell(1,size);
    iterator=javaCollection.iterator();

    counter=1;
    while(iterator.hasNext())

        result{1,counter}=elementConverter(iterator.next());
        counter=counter+1;
    end

end
