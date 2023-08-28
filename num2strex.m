function result = num2strex(num)
    result = {};
    for i=1:length(num)
        result{i} = sprintf('%.0f', num(i));
        if (num(i)>=10000)
            result{i} = fliplr(regexprep(fliplr(result{i}),'\d{3}(?=\d)', '$0,'));
        end
    end
end
