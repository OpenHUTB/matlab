function checkFeedDiameterOnObjects(obj1,obj2)

    if~isequal(obj1.FeedDiameter,obj2.FeedDiameter)
        error(message('rfpcb:rfpcberrors:DifferingFeedDiameters'))
    end