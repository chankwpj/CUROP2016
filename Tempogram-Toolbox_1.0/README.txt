 Tempogram Toolbox 
------------------------------------------------------------------------ 


	The Tempogram Toolbox has been developed by Peter Grosche and Meinard 
	Müller. It contains MATLAB implementations for extracting various types 
	of recently proposed tempo and pulse related audio representations [1, 
	2, 3]. These representations are particularly designed to reveal useful 
	information even for music with weak note onset information and changing 
	tempo. The MATLAB implementations provided on this website are published 
	under the terms of the General Public License (GPL). 


 
 
 License
------------------------------------------------------------------------ 

	'Tempogram Toolbox' is free software: you can redistribute it and/or 
	modify it under the terms of the GNU General Public License as published 
	by the Free Software Foundation, either version 2 of the License, or
	(at your option) any later version.
 
	'Tempogram Toolbox' is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
 
	You should have received a copy of the GNU General Public License
	along with 'Tempogram Toolbox'. If not, see
	<http://www.gnu.org/licenses/>.

	 
	 
 How to use
------------------------------------------------------------------------ 


	Add the toolbox to your MATLAB path and try one of the "test" scripts.
	test_TempogramToolbox.m illustrates the main functionality of the toolbox.
	
	
 Important note
------------------------------------------------------------------------ 
	
	
	Computationally complex parts of the Fourier-based tempogram implementation
	(noveltyCurve_to_tempogram_via_DFT.m) are realized as MEX (MATLAB Executable)
	subroutines produced from C source code, see compute_fourierCoefficients.c.
	
	Pre-compiled versions of these routines are included in the toolbox for 
	Windows (32 bit) and Linux (64 bit) systems for convenience. For all other systems,
	and in the case that the provided MEX files do not work in your setup, you have 
	to compile them calling COMPILE.m. Call "help mex" for further assistance. 
		
	Should it be necessary, you can also call a MATLAB implementation of these routines
	by setting an optional parameter in noveltyCurve_to_tempogram_via_DFT.m 
	(parameter.useImplementation = 2). However, using this workaround, you will observe 
	run-times increasing by a factor of 10!

	
	
	
	