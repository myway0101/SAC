function [Data] = data_LOAD(wnd,class)


% Input 
% wnd: index of signal trial
% focal: 1 for 'focal'; 0 for 'non-focal'

if class == 1
    if wnd < 10
        filename = sprintf('Z00%i.txt',wnd);
    else
        if wnd < 100
            filename = sprintf('Z0%i.txt',wnd);
        else
            filename = sprintf('Z%i.txt',wnd);
        end
    end

elseif class == 2
    if wnd < 10
        filename = sprintf('O00%i.txt',wnd);
    else
        if wnd < 100
            filename = sprintf('O0%i.txt',wnd);
        else
            filename = sprintf('O%i.txt',wnd);
        end
    end
    
    elseif class == 3
    if wnd < 10
        filename = sprintf('N00%i.txt',wnd);
    else
        if wnd < 100
            filename = sprintf('N0%i.txt',wnd);
        else
            filename = sprintf('N%i.txt',wnd);
        end
    end
    
    elseif class == 4
    if wnd < 10
        filename = sprintf('F00%i.txt',wnd);
    else
        if wnd < 100
            filename = sprintf('F0%i.txt',wnd);
        else
            filename = sprintf('F%i.txt',wnd);
        end
    end
    
    elseif class == 5
    if wnd < 10
        filename = sprintf('S00%i.txt',wnd);
    else
        if wnd < 100
            filename = sprintf('S0%i.txt',wnd);
        else
            filename = sprintf('S%i.txt',wnd);
        end
    end
    
    
end

Data = load(filename);
Data = Data';