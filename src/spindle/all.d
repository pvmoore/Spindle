module spindle.all;

public:

import std.stdio                : writefln;
import std.format               : format;
import std.array                : appender;
import std.range                : array;
import std.algorithm.iteration  : map, filter, sum;

import common;
import logging;

import spindle.config;
import spindle.operator;
import spindle.problem;
import spindle.spindle;
import spindle.util;
import spindle.version_;

import spindle.ast.astnode;
import spindle.ast.module_;

import spindle.ast.expr.binary;
import spindle.ast.expr.call;
import spindle.ast.expr.calloc;
import spindle.ast.expr.cast_;
import spindle.ast.expr.default_value;
import spindle.ast.expr.expression;
import spindle.ast.expr.identifier;
import spindle.ast.expr.no_value;
import spindle.ast.expr.null_literal;
import spindle.ast.expr.number_literal;
import spindle.ast.expr.parens;
import spindle.ast.expr.string_literal;
import spindle.ast.expr.unary;
import spindle.ast.expr.unresolved_initialiser;

import spindle.ast.expr.literals.array_literal;
import spindle.ast.expr.literals.function_literal;
import spindle.ast.expr.literals.struct_literal;

import spindle.ast.expr.types.array_decl;
import spindle.ast.expr.types.enum_type_kind;
import spindle.ast.expr.types.function_decl;
import spindle.ast.expr.types.struct_decl;
import spindle.ast.expr.types.type_decl;
import spindle.ast.expr.types.type_expression;
import spindle.ast.expr.types.type_utilities;

import spindle.ast.stmt.return_;
import spindle.ast.stmt.statement;
import spindle.ast.stmt.variable_decl;

import spindle.lex.lexer;
import spindle.lex.token;
import spindle.lex.token_kind;

import spindle.parse.parser;
import spindle.parse.parse_expr;
import spindle.parse.parse_literal;
import spindle.parse.parse_operator;
import spindle.parse.parse_stmt;
import spindle.parse.parse_type;

import spindle.resolve.find_variable;
import spindle.resolve.resolver;
import spindle.resolve.resolve_binary;
import spindle.resolve.resolve_call;
import spindle.resolve.resolve_identifier;
import spindle.resolve.resolve_literal;
import spindle.resolve.resolve_to_typedecl;
import spindle.resolve.resolve_initialiser;
import spindle.resolve.resolve_variable;

import spindle.emit.emitter;

