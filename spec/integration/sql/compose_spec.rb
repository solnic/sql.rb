# frozen_string_literal: true

RSpec.describe SQL, ".compose" do
  let(:result) do
    query.to_s
  end

  describe "SELECT" do
    context "with literals" do
      let(:query) do
        compose {
          SELECT `"users"."id"`, `"users"."name"`
          FROM `"users"`
        }
      end

      specify do
        expect(result).to eql(
          <<~SQL.strip.gsub("\n", " ")
            SELECT "users"."id", "users"."name"
            FROM "users"
          SQL
        )
      end
    end

    context "with literals in WHERE" do
      let(:query) do
        compose {
          SELECT `"users"."id"`, `"users"."name"`
          FROM `"users"`
          WHERE `"users"."name"` == 'Jane'
        }
      end

      specify do
        expect(result).to eql(
          <<~SQL.strip.gsub("\n", " ")
            SELECT "users"."id", "users"."name"
            FROM "users"
            WHERE "users"."name" = 'Jane'
          SQL
        )
      end
    end

    context "inline syntax" do
      let(:query) do
        compose {
          SELECT(`"users"."id"`, `"users"."name"`).FROM(`"users"`)
        }
      end

      specify do
        expect(result).to eql(
          <<~SQL.strip.gsub("\n", " ")
            SELECT "users"."id", "users"."name"
            FROM "users"
          SQL
        )
      end
    end

    context "without WHERE" do
      let(:query) do
        compose { |users|
          SELECT users.id, users.name
          FROM users.table
        }
      end

      specify do
        expect(result.to_s).to eql(
          <<~SQL.strip.gsub("\n", " ")
            SELECT "users"."id", "users"."name"
            FROM "users"
          SQL
        )
      end
    end

    context "with WHERE" do
      let(:query) do
        compose { |users|
          SELECT users.id, users.name
          FROM users.table
          WHERE users.name == "Jane"
        }
      end

      specify do
        expect(result).to eql(
          <<~SQL.strip.gsub("\n", " ")
            SELECT "users"."id", "users"."name"
            FROM "users"
            WHERE "users"."name" = 'Jane'
          SQL
        )
      end
    end

    context "with WHERE and two conditions" do
      let(:query) do
        compose { |users|
          SELECT users.id, users.name
          FROM users.table
          WHERE (users.name == "Jane").OR(users.name == "Jade")
        }
      end

      specify do
        expect(result).to eql(
          <<~SQL.strip.gsub("\n", " ")
            SELECT "users"."id", "users"."name"
            FROM "users"
            WHERE ("users"."name" = 'Jane') OR ("users"."name" = 'Jade')
          SQL
        )
      end
    end

    context "with a dynamic WHERE" do
      let(:query) do
        compose { |users|
          SELECT users.id, users.name
          FROM users.table
          WHERE users.name == "%name%"
        }
      end

      let(:result) do
        query.set(name: "Jane").to_s
      end

      specify do
        expect(result).to eql(
          <<~SQL.strip.gsub("\n", " ")
            SELECT "users"."id", "users"."name"
            FROM "users"
            WHERE "users"."name" = 'Jane'
          SQL
        )
      end
    end

    context "without ORDER" do
      let(:query) do
        compose { |users|
          SELECT users.id, users.name
          FROM users.table
          WHERE users.name == "Jane"
        }
      end

      specify do
        expect(result).to eql(
          <<~SQL.strip.gsub("\n", " ")
            SELECT "users"."id", "users"."name"
            FROM "users"
            WHERE "users"."name" = 'Jane'
          SQL
        )
      end
    end

    context "with ORDER" do
      let(:query) do
        compose { |users|
          SELECT users.id, users.name
          FROM users.table
          WHERE users.name == "Jane"
          ORDER users.id.desc
        }
      end

      specify do
        expect(result).to eql(
          <<~SQL.strip.gsub("\n", " ")
            SELECT "users"."id", "users"."name"
            FROM "users"
            WHERE "users"."name" = 'Jane'
            ORDER BY "users"."id" DESC
          SQL
        )
      end
    end
  end
end
