local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local r = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

local csharp_snippets =
{
	s("exception", fmt(
		[[
		/// <Summary>
		///	An exception that is thrown when {}.
		/// </Summary>
		public class {}Exception : {}Exception
		{{
			/// <Summary>
			///	Initializes a new instance of the <see cref="{}Exception"/> class.
			/// </Summary>
			public {}Exception()
			{{
			}}

			/// <Summary>
			///	Initializes a new instance of the <see cref="{}Exception"/> class with a specified error message.
			/// </Summary>
			/// <paramref name="message">The error message that explains the reason for the exception.</paramref>
			public {}Exception(string message)
				: base(message)
			{{
			}}

			/// <Summary>
			///	Initializes a new instance of the <see cref="{}Exception"/> class with a specified error message
			/// and a reference to the inner exception that is the cause of this exception.
			/// </Summary>
			/// <paramref name="message">The error message that explains the reason for the exception.</paramref>
			/// <paramref name="innerException">The exception that is the cause of the current exception.</paramref>
			public {}Exception(string message, Exception? innerException)
				:base(message, innerException)
			{{
			}}
		}}
		]], { i(3), i(1), i(2), r(1), r(1), r(1), r(1), r(1), r(1) }))
}

ls.add_snippets("cs", csharp_snippets)
