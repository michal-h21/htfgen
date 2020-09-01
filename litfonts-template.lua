local M = {}
M.head = [[
% $Id: tex4ht-fonts-fourier.tex 790 2020-08-31 21:56:35Z karl $
% etex {nameofthefile.tex}
%
% Copyright 2020 TeX Users Group.
% Released under LPPL 1.3c+.
% See tex4ht-cpright.tex for license text.


% Copyright (C) 2018 TeX Users Group

\input tex4ht.sty    
   \Preamble{xhtml,th4,sections+}
\EndPreamble
\input ProTex.sty          
%\AlProTex{c,<<<>>>,`,title,list,ClearCode,_^}
\AlProTex{c,<<<>>>,`,title,list,`,ClearCode,_^}


\def\HOME{./tex4ht.dir/}
\def\DTDS{./dtd.dir/}           
\def\SOURCE{./html.dir/}

\def\MYdir{\HOME texmf/tex4ht/ht-fonts}


\newwrite\dbcs     
\newwrite\unicode  

\def\AddFont{\futurelet\ext\AddFontA}
\def\AddFontA{%
   \if [\ext \def\ext[##1]{\def\ext{##1}\AddFontB}%
   \else     \def\ext{\def\ext{htf}\AddFontB}\fi
   \ext}
\def\AddFontB#1#2{%
   \Comment{}{}\OutputCode[\ext]\<#1\>%
   \let\StartDir=\empty  \def\EndDir{#2}\MakeDir
   \ifx \WWWdir\Undef \else
      \Needs{"cp #1.\ext\space \WWWdir /#2.\ext"}%
      \Needs{"chmod 644 \WWWdir /#2.\ext"}%
   \fi
   \Needs{"mv #1.\ext\space \MYdir /#2.\ext"}%
   }
\def\MakeDir{\relax
   \expandafter \ifx  \csname !\StartDir\endcsname\relax
      \expandafter\let\csname !\StartDir\endcsname=\empty
      \Needs{"mkdir -p \MYdir/\StartDir"}%     
      \ifx \WWWdir\Undef \else
         \Needs{"mkdir -p \MYdir/\StartDir"}%     
         \Needs{"chmod 711 \WWWdir /StartDir"}%
      \fi
   \fi
   \ifx \EndDir\empty \else
       \expandafter\AppendDir \EndDir////*%
       \expandafter\MakeDir
   \fi
}
\def\AppendDir#1/#2/#3/*{%
   \def\temp{#2}\ifx \temp\empty  \let\EndDir=\empty 
   \else
      \edef\StartDir{\ifx \StartDir\empty\else \StartDir/\fi
                     #1}\def\EndDir{#2/#3}%
   \fi
}
]]

M.foot = [[
\bye
]]

return M
