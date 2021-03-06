<cfscript>
describe( "addRow",function(){

	beforeEach( function(){
		variables.rowData = "a,b";
		variables.workbook = s.new();
	});

	it( "Appends a row with the minimum arguments",function() {
		s.addRow( workbook,rowData );
		s.addRow( workbook,"c,d" );// should be inserted at row 2
		expected = QueryNew( "column1,column2","VarChar,VarChar",[ [ "a","b" ],[ "c","d" ] ] );
		actual = s.sheetToQuery( workbook );
		expect( actual ).toBe( expected );
	});

	it( "Appends a row including commas with a custom delimiter",function() {
		s.addRow( workbook=workbook,data="a,b|c,d",delimiter="|" );
		expected = QueryNew( "column1,column2","VarChar,VarChar",[ [ "a,b","c,d" ] ] );
		actual = s.sheetToQuery( workbook );
		expect( actual ).toBe( expected );
	});

	it( "Inserts a row at a specifed position",function() {
		s.addRow( workbook,rowData );
		s.addRow( workbook,"e,f",2,2 );
		s.addRow( workbook,"c,d",2,1 );
		expected = QueryNew( "column1,column2,column3","VarChar,VarChar,VarChar",[ [ "a","b","" ],[ "c","d","" ],[ "","e","f" ] ] );
		actual = s.sheetToQuery( workbook=workbook,includeBlankRows=true );
		expect( actual ).toBe( expected );
	});

	it( "Replaces a row if insert is false",function() {
		s.addRow( workbook,rowData );
		s.addRow( workbook=workbook,data=rowData,row=1,insert=false );
		expected = QueryNew( "column1,column2","VarChar,VarChar",[ [ "a","b" ] ] );
		actual = s.sheetToQuery( workbook );
		expect( actual ).toBe( expected );
	});

	it( "Handles embedded commas",function() {
		s.addRow( workbook=workbook,data="'a,b','c,d'" );
		expected = QueryNew( "column1,column2","VarChar,VarChar",[ [ "a,b","c,d" ] ] );
		actual = s.sheetToQuery( workbook );
		expect( actual ).toBe( expected );
	});

	it( "Adds numeric values correctly",function() {
		var rowData = "1,1.1";
		s.addRow( workbook, rowData );
		expect( s.getCellValue( workbook, 1, 1 ) ).toBe( 1 );
		expect( s.getCellValue( workbook, 1, 2 ) ).toBe( 1.1 );
		expect( s.getCellType( workbook, 1, 1 ) ).toBe( "numeric" );
		expect( s.getCellType( workbook, 1, 2 ) ).toBe( "numeric" );
	});

	it( "Adds boolean values as strings",function() {
		var rowData = true;
		s.addRow( workbook, rowData );
		expect( s.getCellValue( workbook, 1, 1 ) ).toBe( true );
		expect( s.getCellType( workbook, 1, 1 ) ).toBe( "string" );
	});

	it( "Adds date/time values correctly",function() {
		var dateValue = CreateDate( 2015, 04, 12 );
		var timeValue = CreateTime( 1, 0, 0 );
		var dateTimeValue = CreateDateTime( 2015, 04, 12, 1, 0, 0 );
		var rowData = "#dateValue#,#timeValue#,#dateTimeValue#";
		s.addRow( workbook, rowData );
		expect( s.getCellValue( workbook, 1, 1 ) ).toBe( dateValue );
		expect( s.getCellValue( workbook, 1, 2 ) ).toBe( timeValue );
		expect( s.getCellValue( workbook, 1, 3 ) ).toBe( dateTimeValue );
		expect( s.getCellType( workbook, 1, 1 ) ).toBe( "numeric" );
		expect( s.getCellType( workbook, 1, 2 ) ).toBe( "numeric" );
		expect( s.getCellType( workbook, 1, 3 ) ).toBe( "numeric" );
	});

	it( "Adds zeros as zeros, not booleans",function(){
		s.addRow( workbook,0 );
		expect( s.getCellType( workbook, 1, 1 ) ).toBe( "numeric" );
	});

	it( "Adds strings with leading zeros as strings not numbers",function(){
		s.addRow( workbook,"01" );
		expect( s.getCellType( workbook, 1, 1 ) ).toBe( "string" );
	});

	it( "Can insert more than 4009 rows containing dates without triggering an exception",function(){
		for( var i=1; i LTE 4010; i++ ){
			s.addRow( workbook,"2016-07-14" );
		}		
	});

	describe( "addRow throws an exception if", function(){

		it( "row is zero or less",function() {
			expect( function(){
				s.addRow( workbook=workbook,data=rowData,row=0 );
			}).toThrow( regex="Invalid row" );
		});

		it( "column is zero or less",function() {
			expect( function(){
				s.addRow( workbook=workbook,data=rowData,column=0 );
			}).toThrow( regex="Invalid column" );
		});

		it( "insert is false and no row specified",function() {
			expect( function(){
				s.addRow( workbook=workbook,data=rowData,insert=false );
			}).toThrow( regex="Missing row" );
		});

	});

});	
</cfscript>