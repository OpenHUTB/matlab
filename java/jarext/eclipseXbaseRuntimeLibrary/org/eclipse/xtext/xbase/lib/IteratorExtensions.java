// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   IteratorExtensions.java

package org.eclipse.xtext.xbase.lib;

import com.google.common.base.Joiner;
import com.google.common.base.Predicates;
import com.google.common.collect.*;
import java.util.*;
import org.eclipse.xtext.xbase.lib.internal.BooleanFunctionDelegate;
import org.eclipse.xtext.xbase.lib.internal.FunctionDelegate;
import org.eclipse.xtext.xbase.lib.internal.KeyComparator;

// Referenced classes of package org.eclipse.xtext.xbase.lib:
//            Functions, Procedures, Pair

public class IteratorExtensions
{

    public IteratorExtensions()
    {
    }

    public static Iterable toIterable(Iterator iterator)
    {
        if(iterator == null)
            throw new NullPointerException("iterator");
        else
            return new Iterable(iterator) {

                public Iterator iterator()
                {
                    return iterator;
                }

                final Iterator val$iterator;

            
            {
                iterator = iterator1;
                super();
            }
            }
;
    }

    public static Iterator operator_plus(Iterator a, Iterator b)
    {
        return Iterators.concat(a, b);
    }

    public static Object findFirst(Iterator iterator, Functions.Function1 predicate)
    {
        if(predicate == null)
            throw new NullPointerException("predicate");
        while(iterator.hasNext()) 
        {
            Object t = iterator.next();
            if(((Boolean)predicate.apply(t)).booleanValue())
                return t;
        }
        return null;
    }

    public static Object findLast(Iterator iterator, Functions.Function1 predicate)
    {
        if(predicate == null)
            throw new NullPointerException("predicate");
        Object result = null;
        do
        {
            if(!iterator.hasNext())
                break;
            Object t = iterator.next();
            if(((Boolean)predicate.apply(t)).booleanValue())
                result = t;
        } while(true);
        return result;
    }

    public static Object head(Iterator iterator)
    {
        if(iterator.hasNext())
            return iterator.next();
        else
            return null;
    }

    public static Iterator tail(Iterator iterator)
    {
        return drop(iterator, 1);
    }

    public static Object last(Iterator iterator)
    {
        Object result;
        for(result = null; iterator.hasNext(); result = iterator.next());
        return result;
    }

    public static Iterator take(Iterator iterator, int count)
    {
        if(iterator == null)
            throw new NullPointerException("iterator");
        if(count < 0)
            throw new IllegalArgumentException((new StringBuilder()).append("Cannot take a negative number of elements. Argument 'count' was: ").append(count).toString());
        if(count == 0)
            return ImmutableSet.of().iterator();
        else
            return new AbstractIterator(count, iterator) {

                protected Object computeNext()
                {
                    if(remaining <= 0)
                        return endOfData();
                    if(!iterator.hasNext())
                    {
                        return endOfData();
                    } else
                    {
                        remaining--;
                        return iterator.next();
                    }
                }

                private int remaining;
                final int val$count;
                final Iterator val$iterator;

            
            {
                count = i;
                iterator = iterator1;
                super();
                remaining = count;
            }
            }
;
    }

    public static Iterator drop(Iterator iterator, int count)
    {
        if(iterator == null)
            throw new NullPointerException("iterator");
        if(count == 0)
            return iterator;
        if(count < 0)
            throw new IllegalArgumentException((new StringBuilder()).append("Cannot drop a negative number of elements. Argument 'count' was: ").append(count).toString());
        else
            return new AbstractIterator(count, iterator) {

                protected Object computeNext()
                {
                    if(!iterator.hasNext())
                        return endOfData();
                    else
                        return iterator.next();
                }

                final int val$count;
                final Iterator val$iterator;

            
            {
                count = j;
                iterator = iterator1;
                super();
                for(int i = count; i > 0 && iterator.hasNext(); i--)
                    iterator.next();

            }
            }
;
    }

    public static boolean exists(Iterator iterator, Functions.Function1 predicate)
    {
        if(predicate == null)
            throw new NullPointerException("predicate");
        while(iterator.hasNext()) 
            if(((Boolean)predicate.apply(iterator.next())).booleanValue())
                return true;
        return false;
    }

    public static boolean forall(Iterator iterator, Functions.Function1 predicate)
    {
        if(predicate == null)
            throw new NullPointerException("predicate");
        while(iterator.hasNext()) 
            if(!((Boolean)predicate.apply(iterator.next())).booleanValue())
                return false;
        return true;
    }

    public static Iterator filter(Iterator unfiltered, Functions.Function1 predicate)
    {
        return Iterators.filter(unfiltered, new BooleanFunctionDelegate(predicate));
    }

    public static Iterator reject(Iterator unfiltered, Functions.Function1 predicate)
    {
        return Iterators.filter(unfiltered, Predicates.not(new BooleanFunctionDelegate(predicate)));
    }

    public static Iterator filter(Iterator unfiltered, Class type)
    {
        return Iterators.filter(unfiltered, type);
    }

    public static Iterator filterNull(Iterator unfiltered)
    {
        return Iterators.filter(unfiltered, Predicates.notNull());
    }

    public static Iterator map(Iterator original, Functions.Function1 transformation)
    {
        return Iterators.transform(original, new FunctionDelegate(transformation));
    }

    public static Iterator flatMap(Iterator original, Functions.Function1 transformation)
    {
        return flatten(map(original, transformation));
    }

    public static Iterator flatten(Iterator inputs)
    {
        return Iterators.concat(inputs);
    }

    public static void forEach(Iterator iterator, Procedures.Procedure1 procedure)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        for(; iterator.hasNext(); procedure.apply(iterator.next()));
    }

    public static void forEach(Iterator iterator, Procedures.Procedure2 procedure)
    {
        if(procedure == null)
            throw new NullPointerException("procedure");
        int i = 0;
        do
        {
            if(!iterator.hasNext())
                break;
            procedure.apply(iterator.next(), Integer.valueOf(i));
            if(i != 0x7fffffff)
                i++;
        } while(true);
    }

    public static String join(Iterator iterator)
    {
        return join(iterator, "");
    }

    public static String join(Iterator iterator, CharSequence separator)
    {
        return Joiner.on(separator.toString()).useForNull("null").join(toIterable(iterator));
    }

    public static String join(Iterator iterator, CharSequence separator, Functions.Function1 function)
    {
        if(separator == null)
            throw new NullPointerException("separator");
        if(function == null)
            throw new NullPointerException("function");
        StringBuilder result = new StringBuilder();
        do
        {
            if(!iterator.hasNext())
                break;
            Object next = iterator.next();
            CharSequence elementToString = (CharSequence)function.apply(next);
            result.append(elementToString);
            if(iterator.hasNext())
                result.append(separator);
        } while(true);
        return result.toString();
    }

    public static String join(Iterator iterator, CharSequence before, CharSequence separator, CharSequence after, Functions.Function1 function)
    {
        if(function == null)
            throw new NullPointerException("function");
        StringBuilder result = new StringBuilder();
        boolean notEmpty = iterator.hasNext();
        if(notEmpty && before != null)
            result.append(before);
        do
        {
            if(!iterator.hasNext())
                break;
            Object next = iterator.next();
            CharSequence elementToString = (CharSequence)function.apply(next);
            result.append(elementToString);
            if(iterator.hasNext() && separator != null)
                result.append(separator);
        } while(true);
        if(notEmpty && after != null)
            result.append(after);
        return result.toString();
    }

    public static boolean elementsEqual(Iterator iterator, Iterator other)
    {
        return Iterators.elementsEqual(iterator, other);
    }

    public static boolean elementsEqual(Iterator iterator, Iterable iterable)
    {
        return Iterators.elementsEqual(iterator, iterable.iterator());
    }

    public static boolean isNullOrEmpty(Iterator iterator)
    {
        return iterator == null || isEmpty(iterator);
    }

    public static boolean isEmpty(Iterator iterator)
    {
        return !iterator.hasNext();
    }

    public static int size(Iterator iterator)
    {
        return Iterators.size(iterator);
    }

    public static Object reduce(Iterator iterator, Functions.Function2 function)
    {
        if(function == null)
            throw new NullPointerException("function");
        if(iterator.hasNext())
        {
            Object result;
            for(result = iterator.next(); iterator.hasNext(); result = function.apply(result, iterator.next()));
            return result;
        } else
        {
            return null;
        }
    }

    public static Object fold(Iterator iterator, Object seed, Functions.Function2 function)
    {
        Object result;
        for(result = seed; iterator.hasNext(); result = function.apply(result, iterator.next()));
        return result;
    }

    public static List toList(Iterator iterator)
    {
        return Lists.newArrayList(iterator);
    }

    public static Set toSet(Iterator iterator)
    {
        return Sets.newLinkedHashSet(toIterable(iterator));
    }

    public static Map toInvertedMap(Iterator keys, Functions.Function1 computeValues)
    {
        Map result = Maps.newLinkedHashMap();
        Object k;
        for(; keys.hasNext(); result.put(k, computeValues.apply(k)))
            k = keys.next();

        return result;
    }

    public static Map toMap(Iterator values, Functions.Function1 computeKeys)
    {
        if(computeKeys == null)
            throw new NullPointerException("computeKeys");
        Map result = Maps.newLinkedHashMap();
        Object v;
        for(; values.hasNext(); result.put(computeKeys.apply(v), v))
            v = values.next();

        return result;
    }

    public static Map toMap(Iterator inputs, Functions.Function1 computeKeys, Functions.Function1 computeValues)
    {
        if(computeKeys == null)
            throw new NullPointerException("computeKeys");
        if(computeValues == null)
            throw new NullPointerException("computeValues");
        Map result = Maps.newLinkedHashMap();
        Object t;
        for(; inputs.hasNext(); result.put(computeKeys.apply(t), computeValues.apply(t)))
            t = inputs.next();

        return result;
    }

    public static Map groupBy(Iterator values, Functions.Function1 computeKeys)
    {
        if(computeKeys == null)
            throw new NullPointerException("computeKeys");
        Map result = Maps.newLinkedHashMap();
        Object v;
        List grouped;
        for(; values.hasNext(); grouped.add(v))
        {
            v = values.next();
            Object key = computeKeys.apply(v);
            grouped = (List)result.get(key);
            if(grouped == null)
            {
                grouped = new ArrayList();
                result.put(key, grouped);
            }
        }

        return result;
    }

    public static Iterator takeWhile(Iterator iterator, Functions.Function1 predicate)
    {
        if(iterator == null)
            throw new NullPointerException("iterator");
        if(predicate == null)
            throw new NullPointerException("predicate");
        else
            return new AbstractIterator(iterator, predicate) {

                protected Object computeNext()
                {
                    if(!iterator.hasNext())
                        return endOfData();
                    Object next = iterator.next();
                    if(((Boolean)predicate.apply(next)).booleanValue())
                        return next;
                    else
                        return endOfData();
                }

                final Iterator val$iterator;
                final Functions.Function1 val$predicate;

            
            {
                iterator = iterator1;
                predicate = function1;
                super();
            }
            }
;
    }

    public static Iterator dropWhile(Iterator iterator, Functions.Function1 predicate)
    {
        if(iterator == null)
            throw new NullPointerException("iterator");
        if(predicate == null)
            throw new NullPointerException("predicate");
        else
            return new AbstractIterator(iterator, predicate) {

                protected Object computeNext()
                {
                    while(!headFound) 
                    {
                        if(!iterator.hasNext())
                            return endOfData();
                        Object next = iterator.next();
                        if(!((Boolean)predicate.apply(next)).booleanValue())
                        {
                            headFound = true;
                            return next;
                        }
                    }
                    if(iterator.hasNext())
                        return iterator.next();
                    else
                        return endOfData();
                }

                private boolean headFound;
                final Iterator val$iterator;
                final Functions.Function1 val$predicate;

            
            {
                iterator = iterator1;
                predicate = function1;
                super();
                headFound = false;
            }
            }
;
    }

    public static Iterator indexed(Iterator iterator)
    {
        if(iterator == null)
            throw new NullPointerException("iterator");
        else
            return new AbstractIterator(iterator) {

                protected Pair computeNext()
                {
                    if(iterator.hasNext())
                    {
                        Pair next = new Pair(Integer.valueOf(i), iterator.next());
                        if(i != 0x7fffffff)
                            i++;
                        return next;
                    } else
                    {
                        return (Pair)endOfData();
                    }
                }

                protected volatile Object computeNext()
                {
                    return computeNext();
                }

                int i;
                final Iterator val$iterator;

            
            {
                iterator = iterator1;
                super();
                i = 0;
            }
            }
;
    }

    public static Comparable min(Iterator iterator)
    {
        return (Comparable)min(iterator, ((Comparator) (Ordering.natural())));
    }

    public static Object minBy(Iterator iterator, Functions.Function1 compareBy)
    {
        if(compareBy == null)
            throw new NullPointerException("compareBy");
        else
            return min(iterator, new KeyComparator(compareBy));
    }

    public static Object min(Iterator iterator, Comparator comparator)
    {
        if(comparator == null)
            throw new NullPointerException("comparator");
        Object min;
        Object element;
        for(min = iterator.next(); iterator.hasNext(); min = comparator.compare(min, element) > 0 ? element : min)
            element = iterator.next();

        return min;
    }

    public static Comparable max(Iterator iterator)
    {
        return (Comparable)max(iterator, ((Comparator) (Ordering.natural())));
    }

    public static Object maxBy(Iterator iterator, Functions.Function1 compareBy)
    {
        if(compareBy == null)
            throw new NullPointerException("compareBy");
        else
            return max(iterator, new KeyComparator(compareBy));
    }

    public static Object max(Iterator iterator, Comparator comparator)
    {
        if(comparator == null)
            throw new NullPointerException("comparator");
        Object max;
        Object element;
        for(max = iterator.next(); iterator.hasNext(); max = comparator.compare(max, element) < 0 ? element : max)
            element = iterator.next();

        return max;
    }

    public static boolean contains(Iterator iterator, Object o)
    {
        while(iterator.hasNext()) 
            if(Objects.equals(o, iterator.next()))
                return true;
        return false;
    }
}
